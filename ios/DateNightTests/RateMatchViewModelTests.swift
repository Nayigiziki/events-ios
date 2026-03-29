@testable import DateNight
import XCTest

@MainActor
final class RateMatchViewModelTests: XCTestCase {
    private var sut: RateMatchViewModel!
    private var mockService: MockRatingService!
    private let ratedUser = UserProfile(id: UUID(), name: "Emma")

    override func setUp() {
        super.setUp()
        mockService = MockRatingService()
        sut = RateMatchViewModel(ratedUser: ratedUser, ratingService: mockService)
    }

    override func tearDown() {
        sut = nil
        mockService = nil
        super.tearDown()
    }

    // MARK: - Initial State

    func testInitialState() {
        XCTAssertEqual(sut.rating, 0)
        XCTAssertTrue(sut.comment.isEmpty)
        XCTAssertFalse(sut.isSubmitting)
        XCTAssertFalse(sut.didSubmit)
        XCTAssertNil(sut.errorMessage)
        XCTAssertEqual(sut.ratedUser.id, ratedUser.id)
    }

    // MARK: - Submit Rating

    func testSubmitRating_success_callsService() async {
        sut.rating = 4
        sut.comment = "Great date!"

        await sut.submitRating()

        XCTAssertEqual(mockService.submitRatingCallCount, 1)
        XCTAssertEqual(mockService.lastSubmittedRatedUserId, ratedUser.id)
        XCTAssertEqual(mockService.lastSubmittedScore, 4)
        XCTAssertEqual(mockService.lastSubmittedComment, "Great date!")
    }

    func testSubmitRating_success_setsDidSubmit() async {
        sut.rating = 5

        await sut.submitRating()

        XCTAssertTrue(sut.didSubmit)
        XCTAssertFalse(sut.isSubmitting)
    }

    func testSubmitRating_emptyComment_sendsNil() async {
        sut.rating = 3
        sut.comment = ""

        await sut.submitRating()

        XCTAssertEqual(mockService.submitRatingCallCount, 1)
        XCTAssertNil(mockService.lastSubmittedComment)
    }

    func testSubmitRating_whitespaceComment_sendsNil() async {
        sut.rating = 3
        sut.comment = "   "

        await sut.submitRating()

        XCTAssertNil(mockService.lastSubmittedComment)
    }

    func testSubmitRating_zeroRating_doesNothing() async {
        sut.rating = 0

        await sut.submitRating()

        XCTAssertEqual(mockService.submitRatingCallCount, 0)
        XCTAssertFalse(sut.didSubmit)
    }

    func testSubmitRating_failure_setsErrorMessage() async {
        sut.rating = 4
        mockService.submitRatingResult = .failure(NSError(domain: "test", code: 1))

        await sut.submitRating()

        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.didSubmit)
        XCTAssertFalse(sut.isSubmitting)
    }

    // MARK: - Helpers

    func testCanSubmit_zeroRating_returnsFalse() {
        sut.rating = 0
        XCTAssertFalse(sut.canSubmit)
    }

    func testCanSubmit_positiveRating_returnsTrue() {
        sut.rating = 3
        XCTAssertTrue(sut.canSubmit)
    }
}
