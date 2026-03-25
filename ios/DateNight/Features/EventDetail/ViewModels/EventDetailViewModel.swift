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
    @Published var dateType: DateType = .solo
    @Published var groupSize = 2
    @Published var dateDescription = ""
    @Published var comments: [EventComment] = []
    @Published var newCommentText = ""

    enum DateType: String, CaseIterable {
        case solo = "Solo"
        case group = "Group"
    }

    init(event: Event) {
        self.event = event
        loadMockComments()
    }

    func createDate() {
        // Mock implementation - will connect to backend later
        showCreateDate = false
        dateDescription = ""
        dateType = .solo
        groupSize = 2
    }

    func addComment() {
        let trimmed = newCommentText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let comment = EventComment(
            userName: "You",
            avatarUrl: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&h=400&fit=crop",
            text: trimmed,
            timestamp: "Just now",
            upvotes: 0,
            downvotes: 0
        )
        comments.insert(comment, at: 0)
        newCommentText = ""
    }

    func vote(commentId: UUID, direction: EventComment.VoteDirection) {
        guard let index = comments.firstIndex(where: { $0.id == commentId }) else { return }
        let current = comments[index].userVote

        if current == direction {
            // Undo vote
            if direction == .up {
                comments[index].upvotes -= 1
            } else {
                comments[index].downvotes -= 1
            }
            comments[index].userVote = nil
        } else {
            // Remove previous vote if any
            if current == .up {
                comments[index].upvotes -= 1
            } else if current == .down {
                comments[index].downvotes -= 1
            }
            // Apply new vote
            if direction == .up {
                comments[index].upvotes += 1
            } else {
                comments[index].downvotes += 1
            }
            comments[index].userVote = direction
        }
    }

    private func loadMockComments() {
        comments = [
            EventComment(
                userName: "Emma",
                avatarUrl: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&h=400&fit=crop",
                text: "Can't wait for this! Anyone want to grab dinner before?",
                timestamp: "2h ago",
                upvotes: 5,
                downvotes: 0
            ),
            EventComment(
                userName: "Alex",
                avatarUrl: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400&h=400&fit=crop",
                text: "Been to this venue before, the atmosphere is incredible. Highly recommend!",
                timestamp: "4h ago",
                upvotes: 8,
                downvotes: 1
            ),
            EventComment(
                userName: "Sarah",
                avatarUrl: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&h=400&fit=crop",
                text: "Is there parking nearby?",
                timestamp: "6h ago",
                upvotes: 2,
                downvotes: 0
            ),
            EventComment(
                userName: "Michael",
                avatarUrl: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&h=400&fit=crop",
                text: "Just got my ticket! See everyone there.",
                timestamp: "1d ago",
                upvotes: 3,
                downvotes: 0
            )
        ]
    }
}
