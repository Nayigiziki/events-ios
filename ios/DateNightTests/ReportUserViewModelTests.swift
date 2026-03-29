@testable import DateNight
import XCTest

@MainActor
final class ReportUserViewModelTests: XCTestCase {
    private var mockService: MockReportService!
    private var sut: ReportUserViewModel!

    private let testUser = UserProfile(
        id: UUID(),
        name: "Test User",
        age: 25,
        bio: nil,
        avatarUrl: nil,
        photos: [],
        interests: [],
        occupation: nil,
        height: nil
    )

    override func setUp() {
        super.setUp()
        mockService = MockReportService()
        sut = ReportUserViewModel(reportedUser: testUser, reportService: mockService)
    }

    // MARK: - Submit Report

    func testSubmitReportCallsService() async {
        sut.selectedReason = "Spam"
        sut.additionalDetails = "Sending spam messages"

        await sut.submitReport()

        XCTAssertEqual(mockService.submitReportCallCount, 1)
        XCTAssertEqual(mockService.lastReportedUserId, testUser.id)
        XCTAssertEqual(mockService.lastReason, "Spam")
        XCTAssertEqual(mockService.lastDetails, "Sending spam messages")
    }

    func testSubmitReportSetsIsSubmitting() async {
        sut.selectedReason = "Fake profile"

        XCTAssertFalse(sut.isSubmitting)
        await sut.submitReport()
        XCTAssertFalse(sut.isSubmitting)
    }

    func testSubmitReportSetsSuccessOnCompletion() async {
        sut.selectedReason = "Harassment"

        await sut.submitReport()

        XCTAssertTrue(sut.reportSubmitted)
    }

    func testSubmitReportSetsErrorOnFailure() async {
        mockService.shouldFail = true
        sut.selectedReason = "Other"

        await sut.submitReport()

        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.reportSubmitted)
    }

    // MARK: - Block User

    func testBlockUserCallsService() async {
        await sut.blockUser()

        XCTAssertEqual(mockService.blockUserCallCount, 1)
        XCTAssertEqual(mockService.lastBlockedUserId, testUser.id)
    }

    func testBlockUserSetsErrorOnFailure() async {
        mockService.shouldFail = true

        await sut.blockUser()

        XCTAssertNotNil(sut.errorMessage)
    }
}
