import Foundation

struct FriendRelationship: Identifiable, Hashable, Codable {
    let id: UUID
    let userId: UUID
    let friendId: UUID
    let status: FriendStatus
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case friendId = "friend_id"
        case status
        case createdAt = "created_at"
    }
}

enum FriendStatus: String, Codable, Hashable {
    case pending
    case accepted
    case declined
}

protocol FriendServiceProtocol: Sendable {
    func fetchFriends() async throws -> [UserProfile]
    func fetchFriendRequests() async throws -> [FriendRelationship]
    func sendFriendRequest(toUserId: UUID) async throws -> FriendRelationship
    func acceptFriendRequest(requestId: UUID) async throws
    func declineFriendRequest(requestId: UUID) async throws
    func removeFriend(friendId: UUID) async throws
    func searchUsers(query: String) async throws -> [UserProfile]
    func currentUserId() async throws -> UUID
}
