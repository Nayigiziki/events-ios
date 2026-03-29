@testable import DateNight
import Foundation

final class MockFriendService: FriendServiceProtocol, @unchecked Sendable {
    // MARK: - Result Stubs

    var currentUserIdResult: Result<UUID, Error> = .success(UUID())
    var fetchFriendsResult: Result<[UserProfile], Error> = .success([])
    var fetchFriendRequestsResult: Result<[FriendRelationship], Error> = .success([])
    var sendFriendRequestResult: Result<FriendRelationship, Error> = .success(
        FriendRelationship(id: UUID(), userId: UUID(), friendId: UUID(), status: .pending, createdAt: nil)
    )
    var acceptFriendRequestResult: Result<Void, Error> = .success(())
    var declineFriendRequestResult: Result<Void, Error> = .success(())
    var removeFriendResult: Result<Void, Error> = .success(())
    var searchUsersResult: Result<[UserProfile], Error> = .success([])

    // MARK: - Call Tracking

    var fetchFriendsCallCount = 0
    var fetchFriendRequestsCallCount = 0
    var sendFriendRequestCallCount = 0
    var acceptFriendRequestCallCount = 0
    var declineFriendRequestCallCount = 0
    var removeFriendCallCount = 0
    var searchUsersCallCount = 0

    var lastSendRequestToUserId: UUID?
    var lastAcceptRequestId: UUID?
    var lastDeclineRequestId: UUID?
    var lastRemoveFriendId: UUID?
    var lastSearchQuery: String?

    // MARK: - Protocol Implementation

    func currentUserId() async throws -> UUID {
        try currentUserIdResult.get()
    }

    func fetchFriends() async throws -> [UserProfile] {
        fetchFriendsCallCount += 1
        return try fetchFriendsResult.get()
    }

    func fetchFriendRequests() async throws -> [FriendRelationship] {
        fetchFriendRequestsCallCount += 1
        return try fetchFriendRequestsResult.get()
    }

    func sendFriendRequest(toUserId: UUID) async throws -> FriendRelationship {
        sendFriendRequestCallCount += 1
        lastSendRequestToUserId = toUserId
        return try sendFriendRequestResult.get()
    }

    func acceptFriendRequest(requestId: UUID) async throws {
        acceptFriendRequestCallCount += 1
        lastAcceptRequestId = requestId
        try acceptFriendRequestResult.get()
    }

    func declineFriendRequest(requestId: UUID) async throws {
        declineFriendRequestCallCount += 1
        lastDeclineRequestId = requestId
        try declineFriendRequestResult.get()
    }

    func removeFriend(friendId: UUID) async throws {
        removeFriendCallCount += 1
        lastRemoveFriendId = friendId
        try removeFriendResult.get()
    }

    func searchUsers(query: String) async throws -> [UserProfile] {
        searchUsersCallCount += 1
        lastSearchQuery = query
        return try searchUsersResult.get()
    }
}
