@testable import DateNight
import XCTest

@MainActor
final class DateDetailViewModelTests: XCTestCase {
    private var sut: DateDetailViewModel!
    private var mockService: MockDateRequestService!
    private var testDateRequest: DateRequest!

    override func setUp() {
        super.setUp()
        mockService = MockDateRequestService()
        testDateRequest = DateRequest(
            id: UUID(), eventId: UUID(), organizerId: UUID(),
            maxPeople: 4, description: "Test", dateType: .group,
            status: .open
        )
        sut = DateDetailViewModel(dateRequest: testDateRequest, dateRequestService: mockService)
    }

    override func tearDown() {
        sut = nil
        mockService = nil
        super.tearDown()
    }

    // MARK: - Confirm

    func test_confirm_callsServiceAndUpdatesStatus() async {
        await sut.confirm()

        XCTAssertEqual(mockService.confirmDateCalls, [testDateRequest.id])
        XCTAssertEqual(sut.dateRequest.status, .confirmed)
    }

    func test_confirm_setsErrorOnFailure() async {
        mockService.stubbedError = NSError(domain: "test", code: 500)

        await sut.confirm()

        XCTAssertNotNil(sut.errorMessage)
        XCTAssertEqual(sut.dateRequest.status, .open) // unchanged
    }

    // MARK: - Cancel with Confirmation (#64)

    func test_requestCancel_showsConfirmation() {
        sut.requestCancel()

        XCTAssertTrue(sut.showCancelConfirmation)
    }

    func test_confirmCancel_callsServiceAndUpdatesStatus() async {
        await sut.confirmCancel()

        XCTAssertEqual(mockService.cancelDateCalls, [testDateRequest.id])
        XCTAssertEqual(sut.dateRequest.status, .cancelled)
    }

    func test_confirmCancel_setsErrorOnFailure() async {
        mockService.stubbedError = NSError(domain: "test", code: 500)

        await sut.confirmCancel()

        XCTAssertNotNil(sut.errorMessage)
        XCTAssertEqual(sut.dateRequest.status, .open) // unchanged
    }

    // MARK: - Loading

    func test_confirm_setsLoadingState() async {
        XCTAssertFalse(sut.isLoading)
        await sut.confirm()
        XCTAssertFalse(sut.isLoading)
    }
}
