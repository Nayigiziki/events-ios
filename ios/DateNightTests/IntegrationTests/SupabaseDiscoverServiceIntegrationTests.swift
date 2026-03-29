@testable import DateNight
import XCTest

final class SupabaseDiscoverServiceIntegrationTests: XCTestCase {
    var sut: SupabaseDiscoverService!

    override func setUp() async throws {
        try await super.setUp()
        sut = SupabaseDiscoverService()
        try await IntegrationTestHelper.ensureSignedIn()
    }

    override func tearDown() async throws {
        sut = nil
        try await super.tearDown()
    }

    // MARK: - fetchNearbyUsers

    func testFetchNearbyUsers_withDefaultFilters_returnsProfiles() async throws {
        let filters = DiscoverFilters()
        let users = try await sut.fetchNearbyUsers(filters: filters)
        XCTAssertNotNil(users)
        // Current user should not be in results
        let userId = try await IntegrationTestHelper.currentUserId()
        XCTAssertFalse(users.contains(where: { $0.id == userId }))
    }

    func testFetchNearbyUsers_withGenderFilter_returnsFilteredResults() async throws {
        var filters = DiscoverFilters()
        filters.genderPreference = "female"
        let users = try await sut.fetchNearbyUsers(filters: filters)
        for user in users {
            if let gender = user.gender {
                XCTAssertEqual(gender, "female")
            }
        }
    }

    // MARK: - recordSwipe

    func testRecordSwipe_left_returnsRecorded() async throws {
        let filters = DiscoverFilters()
        let users = try await sut.fetchNearbyUsers(filters: filters)
        guard let targetUser = users.first else {
            // No users to swipe on; skip
            return
        }

        let result = try await sut.recordSwipe(userId: targetUser.id, direction: .left)
        XCTAssertEqual(result, .recorded)

        // Clean up
        let client = SupabaseService.shared.client
        let currentUserId = try await client.auth.session.user.id
        try await client.from("swipes")
            .delete()
            .eq("swiper_id", value: currentUserId.uuidString)
            .eq("swiped_id", value: targetUser.id.uuidString)
            .execute()
    }
}
