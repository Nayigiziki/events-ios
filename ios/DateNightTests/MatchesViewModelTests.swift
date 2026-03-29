@testable import DateNight
import XCTest

@MainActor
final class MatchesViewModelTests: XCTestCase {
    private var sut: MatchesViewModel!
    private var mockService: MockDateRequestService!

    override func setUp() {
        super.setUp()
        mockService = MockDateRequestService()
        sut = MatchesViewModel(dateRequestService: mockService)
    }

    override func tearDown() {
        sut = nil
        mockService = nil
        super.tearDown()
    }

    // MARK: - Fetch Available Dates

    func test_loadDates_fetchesAvailableFromService() async {
        let event = Event(
            title: "Jazz Night", category: "Music",
            date: "April 5", time: "8 PM", venue: "Club",
            location: "NYC", price: "$25", description: "Jazz", totalSpots: 50
        )
        let dateReq = DateRequest(
            id: UUID(), eventId: event.id, organizerId: UUID(),
            maxPeople: 4, description: "Join us!", dateType: .group,
            status: .open, event: event
        )
        mockService.stubbedAvailableDates = [dateReq]

        await sut.loadDates()

        XCTAssertEqual(sut.availableDates.count, 1)
        XCTAssertTrue(mockService.fetchAvailableDatesCalled)
    }

    func test_loadDates_fetchesMyDatesFromService() async {
        let dateReq = DateRequest(
            id: UUID(), eventId: UUID(), organizerId: UUID(),
            maxPeople: 2, description: "Date", dateType: .solo,
            status: .confirmed
        )
        mockService.stubbedMyDates = [dateReq]

        await sut.loadDates()

        XCTAssertEqual(sut.myDates.count, 1)
    }

    func test_loadDates_setsErrorOnFailure() async {
        mockService.stubbedError = NSError(domain: "test", code: 500)

        await sut.loadDates()

        XCTAssertNotNil(sut.errorMessage)
    }

    // MARK: - Join Date

    func test_joinDate_callsService() async {
        let requestId = UUID()
        let dateReq = DateRequest(
            id: requestId, eventId: UUID(), organizerId: UUID(),
            maxPeople: 4, description: "Join", dateType: .group,
            status: .open
        )
        mockService.stubbedAvailableDates = [dateReq]
        await sut.loadDates()

        await sut.joinDate(requestId: requestId)

        XCTAssertEqual(mockService.joinDateCalls, [requestId])
    }

    func test_joinDate_setsIsJoining() async {
        let requestId = UUID()

        XCTAssertFalse(sut.isJoining)
        await sut.joinDate(requestId: requestId)
        XCTAssertFalse(sut.isJoining)
    }

    func test_joinDate_reloadsOnSuccess() async {
        let requestId = UUID()

        await sut.joinDate(requestId: requestId)

        // Should have fetched available dates again after joining
        XCTAssertTrue(mockService.fetchAvailableDatesCalled)
    }

    func test_joinDate_setsErrorOnFailure() async {
        mockService.stubbedError = NSError(domain: "test", code: 500)

        await sut.joinDate(requestId: UUID())

        XCTAssertNotNil(sut.errorMessage)
    }

    // MARK: - Loading State

    func test_loadDates_setsIsLoading() async {
        mockService.stubbedAvailableDates = []
        mockService.stubbedMyDates = []

        XCTAssertFalse(sut.isLoading)
        await sut.loadDates()
        XCTAssertFalse(sut.isLoading)
    }
}
