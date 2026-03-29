@testable import DateNight
import XCTest

@MainActor
final class FriendsViewModelTests: XCTestCase {
    private var sut: FriendsViewModel!
    private var mockService: MockFriendService!
    private let currentUserId = UUID()

    override func setUp() {
        super.setUp()
        mockService = MockFriendService()
        mockService.currentUserIdResult = .success(currentUserId)
        sut = FriendsViewModel(friendService: mockService)
    }

    override func tearDown() {
        sut = nil
        mockService = nil
        super.tearDown()
    }

    // MARK: - Initial State

    func testInitialState() {
        XCTAssertTrue(sut.friends.isEmpty)
        XCTAssertTrue(sut.requests.isEmpty)
        XCTAssertTrue(sut.searchResults.isEmpty)
        XCTAssertTrue(sut.searchText.isEmpty)
        XCTAssertTrue(sut.addFriendSearchText.isEmpty)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }

    // MARK: - Load Friends

    func testLoadFriends_success_populatesFriends() async {
        let friends = [
            makeUser(name: "Emma"),
            makeUser(name: "Alex")
        ]
        mockService.fetchFriendsResult = .success(friends)

        await sut.loadFriends()

        XCTAssertEqual(sut.friends.count, 2)
        XCTAssertEqual(mockService.fetchFriendsCallCount, 1)
        XCTAssertFalse(sut.isLoading)
    }

    func testLoadFriends_failure_setsErrorMessage() async {
        mockService.fetchFriendsResult = .failure(NSError(domain: "test", code: 1))

        await sut.loadFriends()

        XCTAssertTrue(sut.friends.isEmpty)
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
    }

    func testLoadFriends_populatesFriendIds() async {
        let friend1 = makeUser(name: "Emma")
        let friend2 = makeUser(name: "Alex")
        mockService.fetchFriendsResult = .success([friend1, friend2])

        await sut.loadFriends()

        XCTAssertTrue(sut.friendIds.contains(friend1.id))
        XCTAssertTrue(sut.friendIds.contains(friend2.id))
    }

    // MARK: - Load Friend Requests

    func testLoadFriendRequests_success_populatesRequests() async {
        let requests = [
            makeFriendRelationship(),
            makeFriendRelationship()
        ]
        mockService.fetchFriendRequestsResult = .success(requests)

        await sut.loadFriendRequests()

        XCTAssertEqual(sut.requests.count, 2)
        XCTAssertEqual(mockService.fetchFriendRequestsCallCount, 1)
    }

    func testLoadFriendRequests_failure_setsErrorMessage() async {
        mockService.fetchFriendRequestsResult = .failure(NSError(domain: "test", code: 1))

        await sut.loadFriendRequests()

        XCTAssertTrue(sut.requests.isEmpty)
        XCTAssertNotNil(sut.errorMessage)
    }

    // MARK: - Accept Request

    func testAcceptRequest_success_removesFromRequests() async {
        let request = makeFriendRelationship()
        mockService.fetchFriendRequestsResult = .success([request])
        await sut.loadFriendRequests()

        await sut.acceptRequest(request)

        XCTAssertTrue(sut.requests.isEmpty)
        XCTAssertEqual(mockService.acceptFriendRequestCallCount, 1)
        XCTAssertEqual(mockService.lastAcceptRequestId, request.id)
    }

    func testAcceptRequest_failure_setsErrorMessage() async {
        let request = makeFriendRelationship()
        mockService.fetchFriendRequestsResult = .success([request])
        await sut.loadFriendRequests()
        mockService.acceptFriendRequestResult = .failure(NSError(domain: "test", code: 1))

        await sut.acceptRequest(request)

        XCTAssertNotNil(sut.errorMessage)
    }

    // MARK: - Decline Request

    func testDeclineRequest_success_removesFromRequests() async {
        let request = makeFriendRelationship()
        mockService.fetchFriendRequestsResult = .success([request])
        await sut.loadFriendRequests()

        await sut.declineRequest(request)

        XCTAssertTrue(sut.requests.isEmpty)
        XCTAssertEqual(mockService.declineFriendRequestCallCount, 1)
        XCTAssertEqual(mockService.lastDeclineRequestId, request.id)
    }

    // MARK: - Remove Friend

    func testRemoveFriend_success_removesFromList() async {
        let friend = makeUser(name: "Emma")
        mockService.fetchFriendsResult = .success([friend])
        await sut.loadFriends()

        await sut.removeFriend(friend)

        XCTAssertTrue(sut.friends.isEmpty)
        XCTAssertFalse(sut.friendIds.contains(friend.id))
        XCTAssertEqual(mockService.removeFriendCallCount, 1)
        XCTAssertEqual(mockService.lastRemoveFriendId, friend.id)
    }

    func testRemoveFriend_failure_setsErrorMessage() async {
        let friend = makeUser(name: "Emma")
        mockService.fetchFriendsResult = .success([friend])
        await sut.loadFriends()
        mockService.removeFriendResult = .failure(NSError(domain: "test", code: 1))

        await sut.removeFriend(friend)

        XCTAssertNotNil(sut.errorMessage)
    }

    // MARK: - Search Users

    func testSearchUsers_success_populatesResults() async {
        let results = [makeUser(name: "Olivia"), makeUser(name: "Liam")]
        mockService.searchUsersResult = .success(results)

        sut.addFriendSearchText = "oli"
        await sut.searchUsers()

        XCTAssertEqual(sut.searchResults.count, 2)
        XCTAssertEqual(mockService.searchUsersCallCount, 1)
        XCTAssertEqual(mockService.lastSearchQuery, "oli")
    }

    func testSearchUsers_emptyQuery_clearsResults() async {
        sut.addFriendSearchText = ""

        await sut.searchUsers()

        XCTAssertTrue(sut.searchResults.isEmpty)
        XCTAssertEqual(mockService.searchUsersCallCount, 0)
    }

    func testSearchUsers_failure_setsErrorMessage() async {
        mockService.searchUsersResult = .failure(NSError(domain: "test", code: 1))
        sut.addFriendSearchText = "test"

        await sut.searchUsers()

        XCTAssertNotNil(sut.errorMessage)
    }

    // MARK: - Send Friend Request

    func testSendFriendRequest_success_callsService() async {
        let targetUser = makeUser(name: "Olivia")

        await sut.sendFriendRequest(to: targetUser)

        XCTAssertEqual(mockService.sendFriendRequestCallCount, 1)
        XCTAssertEqual(mockService.lastSendRequestToUserId, targetUser.id)
    }

    func testSendFriendRequest_failure_setsErrorMessage() async {
        mockService.sendFriendRequestResult = .failure(NSError(domain: "test", code: 1))
        let targetUser = makeUser(name: "Olivia")

        await sut.sendFriendRequest(to: targetUser)

        XCTAssertNotNil(sut.errorMessage)
    }

    // MARK: - Filtered Friends

    func testFilteredFriends_emptySearch_returnsAll() async {
        let friends = [makeUser(name: "Emma"), makeUser(name: "Alex")]
        mockService.fetchFriendsResult = .success(friends)
        await sut.loadFriends()

        sut.searchText = ""

        XCTAssertEqual(sut.filteredFriends.count, 2)
    }

    func testFilteredFriends_matchingSearch_filtersResults() async {
        let friends = [makeUser(name: "Emma"), makeUser(name: "Alex")]
        mockService.fetchFriendsResult = .success(friends)
        await sut.loadFriends()

        sut.searchText = "emm"

        XCTAssertEqual(sut.filteredFriends.count, 1)
        XCTAssertEqual(sut.filteredFriends.first?.name, "Emma")
    }

    // MARK: - Helpers

    private func makeUser(name: String) -> UserProfile {
        UserProfile(id: UUID(), name: name)
    }

    private func makeFriendRelationship() -> FriendRelationship {
        FriendRelationship(
            id: UUID(),
            userId: UUID(),
            friendId: currentUserId,
            status: .pending,
            createdAt: Date()
        )
    }
}
