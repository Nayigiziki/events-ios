import Foundation

@MainActor
class FriendsViewModel: ObservableObject {
    @Published var friends: [UserProfile] = []
    @Published var requests: [FriendRelationship] = []
    @Published var searchResults: [UserProfile] = []
    @Published var searchText: String = ""
    @Published var addFriendSearchText: String = ""
    @Published var friendIds: Set<UUID> = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let friendService: any FriendServiceProtocol

    init(friendService: any FriendServiceProtocol = SupabaseFriendService()) {
        self.friendService = friendService
    }

    var filteredFriends: [UserProfile] {
        if searchText.isEmpty {
            return friends
        }
        return friends.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    func loadFriends() async {
        isLoading = true
        errorMessage = nil
        do {
            friends = try await friendService.fetchFriends()
            friendIds = Set(friends.map(\.id))
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func loadFriendRequests() async {
        errorMessage = nil
        do {
            requests = try await friendService.fetchFriendRequests()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func acceptRequest(_ request: FriendRelationship) async {
        errorMessage = nil
        do {
            try await friendService.acceptFriendRequest(requestId: request.id)
            requests.removeAll { $0.id == request.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func declineRequest(_ request: FriendRelationship) async {
        errorMessage = nil
        do {
            try await friendService.declineFriendRequest(requestId: request.id)
            requests.removeAll { $0.id == request.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func removeFriend(_ friend: UserProfile) async {
        errorMessage = nil
        do {
            try await friendService.removeFriend(friendId: friend.id)
            friends.removeAll { $0.id == friend.id }
            friendIds.remove(friend.id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func sendFriendRequest(to user: UserProfile) async {
        errorMessage = nil
        do {
            _ = try await friendService.sendFriendRequest(toUserId: user.id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func searchUsers() async {
        let query = addFriendSearchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        errorMessage = nil
        do {
            searchResults = try await friendService.searchUsers(query: query)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
