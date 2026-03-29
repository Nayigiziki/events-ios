@testable import DateNight
import XCTest

final class SupabaseFriendServiceIntegrationTests: XCTestCase {
    var sut: SupabaseFriendService!

    override func setUp() async throws {
        try await super.setUp()
        sut = SupabaseFriendService()
        try await IntegrationTestHelper.ensureSignedIn()
    }

    override func tearDown() async throws {
        sut = nil
        try await super.tearDown()
    }

    // MARK: - fetchFriends (stub - returns empty)

    func testFetchFriends_returnsEmptyArray() async throws {
        let friends = try await sut.fetchFriends()
        XCTAssertTrue(friends.isEmpty)
    }

    // MARK: - fetchFriendRequests (stub - returns empty)

    func testFetchFriendRequests_returnsEmptyArray() async throws {
        let requests = try await sut.fetchFriendRequests()
        XCTAssertTrue(requests.isEmpty)
    }

    // MARK: - sendFriendRequest (stub - returns placeholder)

    func testSendFriendRequest_returnsPlaceholderRelationship() async throws {
        let targetUserId = UUID()
        let relationship = try await sut.sendFriendRequest(toUserId: targetUserId)
        XCTAssertEqual(relationship.status, .pending)
        XCTAssertEqual(relationship.friendId, targetUserId)
    }

    // MARK: - acceptFriendRequest (stub - no-op)

    func testAcceptFriendRequest_doesNotThrow() async throws {
        try await sut.acceptFriendRequest(requestId: UUID())
    }

    // MARK: - declineFriendRequest (stub - no-op)

    func testDeclineFriendRequest_doesNotThrow() async throws {
        try await sut.declineFriendRequest(requestId: UUID())
    }

    // MARK: - searchUsers (stub - returns empty)

    func testSearchUsers_returnsEmptyArray() async throws {
        let users = try await sut.searchUsers(query: "test")
        XCTAssertTrue(users.isEmpty)
    }

    // MARK: - currentUserId

    func testCurrentUserId_returnsAuthenticatedUserId() async throws {
        let userId = try await sut.currentUserId()
        let expectedId = try await IntegrationTestHelper.currentUserId()
        XCTAssertEqual(userId, expectedId)
    }
}
