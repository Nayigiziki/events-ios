@testable import DateNight
import XCTest

final class SupabaseRatingServiceIntegrationTests: XCTestCase {
    var sut: SupabaseRatingService!

    override func setUp() async throws {
        try await super.setUp()
        sut = SupabaseRatingService()
        try await IntegrationTestHelper.ensureSignedIn()
    }

    override func tearDown() async throws {
        sut = nil
        try await super.tearDown()
    }

    // MARK: - submitRating (stub - returns placeholder)

    func testSubmitRating_returnsPlaceholderRating() async throws {
        let targetUserId = UUID()
        let rating = try await sut.submitRating(ratedUserId: targetUserId, score: 4, comment: "Great date!")
        XCTAssertEqual(rating.score, 4)
        XCTAssertEqual(rating.comment, "Great date!")
        XCTAssertEqual(rating.ratedUserId, targetUserId)
    }

    // MARK: - fetchRatingsForUser (stub - returns empty)

    func testFetchRatingsForUser_returnsEmptyArray() async throws {
        let ratings = try await sut.fetchRatingsForUser(userId: UUID())
        XCTAssertTrue(ratings.isEmpty)
    }

    // MARK: - fetchMyRatings (stub - returns empty)

    func testFetchMyRatings_returnsEmptyArray() async throws {
        let ratings = try await sut.fetchMyRatings()
        XCTAssertTrue(ratings.isEmpty)
    }

    // MARK: - currentUserId

    func testCurrentUserId_returnsAuthenticatedUserId() async throws {
        let userId = try await sut.currentUserId()
        let expectedId = try await IntegrationTestHelper.currentUserId()
        XCTAssertEqual(userId, expectedId)
    }
}
