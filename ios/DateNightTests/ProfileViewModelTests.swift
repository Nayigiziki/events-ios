@testable import DateNight
import XCTest

@MainActor
final class ProfileViewModelTests: XCTestCase {
    var sut: ProfileViewModel!
    var mockService: MockProfileService!
    let testUserId = UUID()

    override func setUp() {
        super.setUp()
        mockService = MockProfileService()
        sut = ProfileViewModel(profileService: mockService, userId: testUserId)
    }

    override func tearDown() {
        sut = nil
        mockService = nil
        super.tearDown()
    }

    // MARK: - loadProfile

    func testLoadProfile_fetchesProfileFromService() async {
        let expectedProfile = UserProfile(
            id: testUserId,
            name: "Alice",
            age: 28,
            bio: "Hello",
            photos: ["p1"],
            interests: ["Art"]
        )
        mockService.fetchProfileResult = .success(expectedProfile)

        await sut.loadProfile()

        XCTAssertEqual(mockService.fetchProfileCallCount, 1)
        XCTAssertEqual(sut.profile?.name, "Alice")
        XCTAssertEqual(sut.profile?.age, 28)
    }

    func testLoadProfile_fetchesStats() async {
        mockService.fetchStatsResult = .success(ProfileStats(matches: 10, dates: 5, events: 20))

        await sut.loadProfile()

        XCTAssertEqual(mockService.fetchStatsCallCount, 1)
        XCTAssertEqual(sut.stats.matches, 10)
        XCTAssertEqual(sut.stats.dates, 5)
        XCTAssertEqual(sut.stats.events, 20)
    }

    func testLoadProfile_fetchesActivity() async {
        let activities = [
            Activity(
                id: "a1",
                icon: "heart.fill",
                iconColor: "pink",
                title: "Matched with Bob",
                subtitle: "Jazz Night",
                timeAgo: "1d"
            )
        ]
        mockService.fetchActivityResult = .success(activities)

        await sut.loadProfile()

        XCTAssertEqual(mockService.fetchActivityCallCount, 1)
        XCTAssertEqual(sut.activities.count, 1)
        XCTAssertEqual(sut.activities.first?.title, "Matched with Bob")
    }

    func testLoadProfile_setsIsLoading() async {
        XCTAssertFalse(sut.isLoading)

        await sut.loadProfile()

        XCTAssertFalse(sut.isLoading)
    }

    func testLoadProfile_onError_setsErrorMessage() async {
        mockService.fetchProfileResult = .failure(NSError(
            domain: "test",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "Network error"]
        ))

        await sut.loadProfile()

        XCTAssertNotNil(sut.errorMessage)
        XCTAssertNil(sut.profile)
    }
}
