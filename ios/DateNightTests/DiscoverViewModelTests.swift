@testable import DateNight
import XCTest

@MainActor
final class DiscoverViewModelTests: XCTestCase {
    private var sut: DiscoverViewModel!
    private var mockService: MockDiscoverService!

    override func setUp() {
        super.setUp()
        mockService = MockDiscoverService()
        sut = DiscoverViewModel(discoverService: mockService)
    }

    override func tearDown() {
        sut = nil
        mockService = nil
        super.tearDown()
    }

    // MARK: - Fetch Users

    func test_loadUsers_fetchesFromService() async {
        let users = [
            UserProfile(name: "Alice", age: 25, interests: ["Music"]),
            UserProfile(name: "Bob", age: 28, interests: ["Art"])
        ]
        mockService.stubbedUsers = users

        await sut.loadUsers()

        XCTAssertEqual(sut.users.count, 2)
        XCTAssertEqual(sut.users[0].name, "Alice")
        XCTAssertEqual(sut.users[1].name, "Bob")
        XCTAssertEqual(mockService.fetchNearbyUsersCalls.count, 1)
    }

    func test_loadUsers_setsIsLoading() async {
        mockService.stubbedUsers = []

        XCTAssertFalse(sut.isLoading)
        await sut.loadUsers()
        XCTAssertFalse(sut.isLoading)
    }

    func test_loadUsers_setsErrorOnFailure() async {
        mockService.stubbedError = NSError(domain: "test", code: 500)

        await sut.loadUsers()

        XCTAssertNotNil(sut.errorMessage)
        XCTAssertTrue(sut.users.isEmpty)
    }

    func test_loadUsers_passesFiltersToService() async {
        sut.filters = DiscoverFilters(
            minAge: 21,
            maxAge: 35,
            maxDistance: 10,
            interests: ["Music"],
            genderPreference: "female"
        )
        mockService.stubbedUsers = []

        await sut.loadUsers()

        XCTAssertEqual(mockService.fetchNearbyUsersCalls.count, 1)
        let passedFilters = mockService.fetchNearbyUsersCalls[0]
        XCTAssertEqual(passedFilters.minAge, 21)
        XCTAssertEqual(passedFilters.maxAge, 35)
        XCTAssertEqual(passedFilters.maxDistance, 10)
        XCTAssertEqual(passedFilters.interests, ["Music"])
        XCTAssertEqual(passedFilters.genderPreference, "female")
    }

    // MARK: - Current User

    func test_currentUser_returnsNilWhenEmpty() {
        XCTAssertNil(sut.currentUser)
    }

    func test_currentUser_returnsFirstAfterLoad() async {
        mockService.stubbedUsers = [
            UserProfile(name: "Alice", interests: [])
        ]
        await sut.loadUsers()

        XCTAssertEqual(sut.currentUser?.name, "Alice")
    }

    func test_currentUser_returnsNilAtEnd() async {
        mockService.stubbedUsers = [
            UserProfile(name: "Alice", interests: [])
        ]
        await sut.loadUsers()

        // Swipe past the only user
        await sut.swipeLeft(userId: sut.users[0].id)

        XCTAssertNil(sut.currentUser)
    }

    // MARK: - Swipe Right (Like)

    func test_swipeRight_recordsSwipeViaService() async {
        let user = UserProfile(name: "Alice", interests: [])
        mockService.stubbedUsers = [user]
        await sut.loadUsers()

        mockService.stubbedSwipeResult = .recorded

        await sut.swipeRight(userId: user.id)

        XCTAssertEqual(mockService.recordSwipeCalls.count, 1)
        XCTAssertEqual(mockService.recordSwipeCalls[0].userId, user.id)
        XCTAssertEqual(mockService.recordSwipeCalls[0].direction, .right)
    }

    func test_swipeRight_advancesIndex() async {
        let users = [
            UserProfile(name: "Alice", interests: []),
            UserProfile(name: "Bob", interests: [])
        ]
        mockService.stubbedUsers = users
        await sut.loadUsers()

        await sut.swipeRight(userId: users[0].id)

        XCTAssertEqual(sut.currentUser?.name, "Bob")
    }

    func test_swipeRight_showsMatchOnMutualMatch() async {
        let user = UserProfile(name: "Alice", interests: [])
        mockService.stubbedUsers = [user]
        await sut.loadUsers()

        let match = Match(id: UUID(), user1Id: UUID(), user2Id: user.id)
        mockService.stubbedSwipeResult = .matched(match)

        await sut.swipeRight(userId: user.id)

        XCTAssertTrue(sut.showMatchDetail)
        XCTAssertEqual(sut.matchedUser?.name, "Alice")
    }

    func test_swipeRight_doesNotShowMatchOnRecorded() async {
        let user = UserProfile(name: "Alice", interests: [])
        mockService.stubbedUsers = [user]
        await sut.loadUsers()

        mockService.stubbedSwipeResult = .recorded

        await sut.swipeRight(userId: user.id)

        XCTAssertFalse(sut.showMatchDetail)
        XCTAssertNil(sut.matchedUser)
    }

    // MARK: - Swipe Left (Pass)

    func test_swipeLeft_recordsSwipeViaService() async {
        let user = UserProfile(name: "Alice", interests: [])
        mockService.stubbedUsers = [user]
        await sut.loadUsers()

        await sut.swipeLeft(userId: user.id)

        XCTAssertEqual(mockService.recordSwipeCalls.count, 1)
        XCTAssertEqual(mockService.recordSwipeCalls[0].direction, .left)
    }

    func test_swipeLeft_advancesIndex() async {
        let users = [
            UserProfile(name: "Alice", interests: []),
            UserProfile(name: "Bob", interests: [])
        ]
        mockService.stubbedUsers = users
        await sut.loadUsers()

        await sut.swipeLeft(userId: users[0].id)

        XCTAssertEqual(sut.currentUser?.name, "Bob")
    }

    // MARK: - No Infinite Cycling (#46)

    func test_doesNotCycleBackToStart() async {
        let users = [
            UserProfile(name: "Alice", interests: []),
            UserProfile(name: "Bob", interests: [])
        ]
        mockService.stubbedUsers = users
        await sut.loadUsers()

        await sut.swipeLeft(userId: users[0].id)
        await sut.swipeLeft(userId: users[1].id)

        // Should be nil (empty state), not cycling back to Alice
        XCTAssertNil(sut.currentUser)
        XCTAssertEqual(sut.currentIndex, 2)
    }

    // MARK: - Dismiss Match

    func test_dismissMatch_clearsState() async {
        let user = UserProfile(name: "Alice", interests: [])
        mockService.stubbedUsers = [user]
        await sut.loadUsers()

        let match = Match(id: UUID(), user1Id: UUID(), user2Id: user.id)
        mockService.stubbedSwipeResult = .matched(match)
        await sut.swipeRight(userId: user.id)

        sut.dismissMatch()

        XCTAssertFalse(sut.showMatchDetail)
        XCTAssertNil(sut.matchedUser)
    }

    // MARK: - Next User

    func test_nextUser_returnsNextInList() async {
        let users = [
            UserProfile(name: "Alice", interests: []),
            UserProfile(name: "Bob", interests: [])
        ]
        mockService.stubbedUsers = users
        await sut.loadUsers()

        XCTAssertEqual(sut.nextUser?.name, "Bob")
    }

    func test_nextUser_returnsNilAtEnd() async {
        let users = [
            UserProfile(name: "Alice", interests: [])
        ]
        mockService.stubbedUsers = users
        await sut.loadUsers()

        XCTAssertNil(sut.nextUser)
    }
}
