import Foundation

struct FriendUser: Identifiable, Hashable {
    let id: UUID
    let name: String
    let avatarUrl: String?
    let subtitle: String
}

struct FriendRequest: Identifiable, Hashable {
    let id: UUID
    let user: FriendUser
    let sentAt: String
}

@MainActor
class FriendsViewModel: ObservableObject {
    @Published var friends: [FriendUser] = []
    @Published var requests: [FriendRequest] = []
    @Published var searchResults: [FriendUser] = []
    @Published var searchText: String = ""
    @Published var addFriendSearchText: String = ""
    @Published var friendIds: Set<UUID> = []

    init() {
        loadMockData()
    }

    private func loadMockData() {
        let friend1 = FriendUser(
            id: UUID(),
            name: "Emma",
            avatarUrl: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&h=400&fit=crop",
            subtitle: "Jazz enthusiast"
        )
        let friend2 = FriendUser(
            id: UUID(),
            name: "Alex",
            avatarUrl: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400&h=400&fit=crop",
            subtitle: "Concert junkie"
        )
        let friend3 = FriendUser(
            id: UUID(),
            name: "Sarah",
            avatarUrl: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&h=400&fit=crop",
            subtitle: "Art lover"
        )
        let friend4 = FriendUser(
            id: UUID(),
            name: "Michael",
            avatarUrl: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&h=400&fit=crop",
            subtitle: "Wine connoisseur"
        )

        friends = [friend1, friend2, friend3, friend4]
        friendIds = Set(friends.map(\.id))

        let req1 = FriendUser(
            id: UUID(),
            name: "Jessica",
            avatarUrl: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&h=400&fit=crop",
            subtitle: "Yoga instructor"
        )
        let req2 = FriendUser(
            id: UUID(),
            name: "David",
            avatarUrl: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop",
            subtitle: "Food explorer"
        )

        requests = [
            FriendRequest(id: UUID(), user: req1, sentAt: "2h ago"),
            FriendRequest(id: UUID(), user: req2, sentAt: "1d ago")
        ]
    }

    var filteredFriends: [FriendUser] {
        if searchText.isEmpty {
            return friends
        }
        return friends.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    func acceptRequest(_ request: FriendRequest) {
        requests.removeAll { $0.id == request.id }
        friends.append(request.user)
        friendIds.insert(request.user.id)
    }

    func declineRequest(_ request: FriendRequest) {
        requests.removeAll { $0.id == request.id }
    }

    func removeFriend(_ friend: FriendUser) {
        friends.removeAll { $0.id == friend.id }
        friendIds.remove(friend.id)
    }

    func addFriend(_ user: FriendUser) {
        friends.append(user)
        friendIds.insert(user.id)
    }

    func searchUsers() {
        guard !addFriendSearchText.isEmpty else {
            searchResults = []
            return
        }

        // Mock search results
        let allUsers: [FriendUser] = [
            FriendUser(
                id: UUID(),
                name: "Olivia Chen",
                avatarUrl: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&h=400&fit=crop",
                subtitle: "Music lover"
            ),
            FriendUser(
                id: UUID(),
                name: "Liam Park",
                avatarUrl: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400&h=400&fit=crop",
                subtitle: "Outdoor adventurer"
            ),
            FriendUser(
                id: UUID(),
                name: "Sophia Martinez",
                avatarUrl: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&h=400&fit=crop",
                subtitle: "Foodie"
            )
        ]

        searchResults = allUsers.filter {
            $0.name.localizedCaseInsensitiveContains(addFriendSearchText)
        }
    }
}
