import Foundation
import SwiftUI

// MARK: - Comment Model

struct EventComment: Identifiable, Hashable {
    let id: UUID
    let userName: String
    let avatarUrl: String?
    let text: String
    let timestamp: String
    var upvotes: Int
    var downvotes: Int
    var userVote: VoteDirection?

    enum VoteDirection: Hashable {
        case up, down
    }

    init(
        id: UUID = UUID(),
        userName: String,
        avatarUrl: String? = nil,
        text: String,
        timestamp: String,
        upvotes: Int = 0,
        downvotes: Int = 0,
        userVote: VoteDirection? = nil
    ) {
        self.id = id
        self.userName = userName
        self.avatarUrl = avatarUrl
        self.text = text
        self.timestamp = timestamp
        self.upvotes = upvotes
        self.downvotes = downvotes
        self.userVote = userVote
    }
}

// MARK: - ViewModel

@MainActor
final class EventDetailViewModel: ObservableObject {
    @Published var event: Event?
    @Published var showCreateDate = false
    @Published var showShareSheet = false
    @Published var dateType: DateType = .solo
    @Published var groupSize = 2
    @Published var dateDescription = ""
    @Published var comments: [EventComment] = []
    @Published var newCommentText = ""
    @Published var isAttending = false
    @Published var errorMessage: String?
    @Published var invitableUsers: [UserProfile] = []
    @Published var invitedUserIds: Set<UUID> = []

    enum DateType: String, CaseIterable {
        case solo = "Solo"
        case group = "Group"
    }

    private let eventService: any EventServiceProtocol
    private let friendService: any FriendServiceProtocol

    init(
        event: Event,
        eventService: any EventServiceProtocol = SupabaseEventService(),
        friendService: any FriendServiceProtocol = SupabaseFriendService()
    ) {
        self.event = event
        self.eventService = eventService
        self.friendService = friendService
    }

    func loadInvitableUsers() async {
        do {
            invitableUsers = try await friendService.fetchFriends()
        } catch {
            // Non-critical — user can still create a date without invites
        }
    }

    func toggleInvite(_ userId: UUID) {
        if invitedUserIds.contains(userId) {
            invitedUserIds.remove(userId)
        } else {
            invitedUserIds.insert(userId)
        }
    }

    func loadComments() async {
        guard let event else { return }
        do {
            comments = try await eventService.fetchComments(eventId: event.id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addComment() async {
        guard let event else { return }
        let trimmed = newCommentText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        do {
            let comment = try await eventService.addComment(
                EventCommentCreateRequest(eventId: event.id, text: trimmed)
            )
            comments.insert(comment, at: 0)
            newCommentText = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func vote(commentId: UUID, direction: EventComment.VoteDirection) async {
        guard let index = comments.firstIndex(where: { $0.id == commentId }) else { return }
        let current = comments[index].userVote

        // Optimistic update
        if current == direction {
            if direction == .up {
                comments[index].upvotes -= 1
            } else {
                comments[index].downvotes -= 1
            }
            comments[index].userVote = nil
        } else {
            if current == .up {
                comments[index].upvotes -= 1
            } else if current == .down {
                comments[index].downvotes -= 1
            }
            if direction == .up {
                comments[index].upvotes += 1
            } else {
                comments[index].downvotes += 1
            }
            comments[index].userVote = direction
        }

        // Persist to backend
        do {
            try await eventService.voteComment(
                CommentVoteRequest(commentId: commentId, direction: direction)
            )
        } catch {
            // Vote is optimistic — silently fail
        }
    }

    var shareText: String {
        guard let event else { return "" }
        return "Check out \(event.title) at \(event.venue) on \(event.date)!"
    }

    func rsvp() async {
        guard let event else { return }
        errorMessage = nil
        do {
            try await eventService.rsvpEvent(event.id)
            isAttending = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func unrsvp() async {
        guard let event else { return }
        do {
            try await eventService.unrsvpEvent(event.id)
            isAttending = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func createDate() async {
        guard let event else { return }
        do {
            try await eventService.createDate(DateCreateRequest(
                eventId: event.id,
                dateType: dateType.rawValue,
                groupSize: groupSize,
                description: dateDescription,
                invitedUserIds: Array(invitedUserIds)
            ))
            showCreateDate = false
            dateDescription = ""
            dateType = .solo
            groupSize = 2
            invitedUserIds = []
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
