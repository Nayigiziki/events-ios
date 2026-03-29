@testable import DateNight
import XCTest

@MainActor
final class MyReviewsViewModelTests: XCTestCase {
    private var mockService: MockReviewService!
    private var sut: MyReviewsViewModel!
    private let testUserId = UUID()

    private func makeReview(stars: Int, comment: String? = nil) -> DateReview {
        DateReview(
            id: UUID(),
            reviewerId: UUID(),
            reviewedUserId: testUserId,
            stars: stars,
            comment: comment,
            createdAt: Date(),
            reviewer: UserProfile(
                id: UUID(),
                name: "Reviewer",
                age: 25,
                bio: nil,
                avatarUrl: nil,
                photos: [],
                interests: [],
                occupation: nil,
                height: nil
            )
        )
    }

    override func setUp() {
        super.setUp()
        mockService = MockReviewService()
        sut = MyReviewsViewModel(reviewService: mockService, userId: testUserId)
    }

    func testLoadReviewsFetchesFromService() async {
        mockService.stubbedReviews = [makeReview(stars: 5), makeReview(stars: 4)]

        await sut.loadReviews()

        XCTAssertEqual(mockService.fetchCallCount, 1)
        XCTAssertEqual(sut.reviews.count, 2)
    }

    func testAverageRatingCalculation() async {
        mockService.stubbedReviews = [
            makeReview(stars: 5),
            makeReview(stars: 3),
            makeReview(stars: 4)
        ]

        await sut.loadReviews()

        XCTAssertEqual(sut.averageRating, 4.0, accuracy: 0.01)
    }

    func testAverageRatingIsZeroWhenNoReviews() async {
        mockService.stubbedReviews = []

        await sut.loadReviews()

        XCTAssertEqual(sut.averageRating, 0.0)
    }

    func testLoadReviewsSetsErrorOnFailure() async {
        mockService.shouldFail = true

        await sut.loadReviews()

        XCTAssertNotNil(sut.errorMessage)
        XCTAssertTrue(sut.reviews.isEmpty)
    }

    func testIsLoadingDuringFetch() async {
        await sut.loadReviews()

        XCTAssertFalse(sut.isLoading)
    }
}
