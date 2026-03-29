@testable import DateNight
import XCTest

@MainActor
final class MyDatesViewModelTests: XCTestCase {
    private var sut: MyDatesViewModel!
    private var mockService: MockDateRequestService!

    override func setUp() {
        super.setUp()
        mockService = MockDateRequestService()
        sut = MyDatesViewModel(dateRequestService: mockService)
    }

    override func tearDown() {
        sut = nil
        mockService = nil
        super.tearDown()
    }

    // MARK: - Load Dates

    func test_loadDates_fetchesFromService() async {
        let openDate = DateRequest(
            id: UUID(), eventId: UUID(), organizerId: UUID(),
            maxPeople: 2, description: "Open", dateType: .solo, status: .open
        )
        let confirmedDate = DateRequest(
            id: UUID(), eventId: UUID(), organizerId: UUID(),
            maxPeople: 4, description: "Confirmed", dateType: .group, status: .confirmed
        )
        let cancelledDate = DateRequest(
            id: UUID(), eventId: UUID(), organizerId: UUID(),
            maxPeople: 2, description: "Cancelled", dateType: .solo, status: .cancelled
        )
        mockService.stubbedMyDates = [openDate, confirmedDate, cancelledDate]

        await sut.loadDates()

        XCTAssertEqual(sut.upcoming.count, 2) // open + confirmed
        XCTAssertEqual(sut.cancelled.count, 1)
        XCTAssertEqual(mockService.fetchMyDatesCalls.count, 1)
    }

    func test_loadDates_setsErrorOnFailure() async {
        mockService.stubbedError = NSError(domain: "test", code: 500)

        await sut.loadDates()

        XCTAssertNotNil(sut.errorMessage)
    }

    func test_loadDates_setsLoadingState() async {
        XCTAssertFalse(sut.isLoading)
        await sut.loadDates()
        XCTAssertFalse(sut.isLoading)
    }
}
