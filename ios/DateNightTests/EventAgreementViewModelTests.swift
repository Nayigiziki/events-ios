@testable import DateNight
import XCTest

@MainActor
final class EventAgreementViewModelTests: XCTestCase {
    private var sut: EventAgreementViewModel!
    private var mockService: MockEventAgreementService!
    private let matchId = UUID()

    override func setUp() {
        super.setUp()
        mockService = MockEventAgreementService()
        sut = EventAgreementViewModel(service: mockService, matchId: matchId)
    }

    override func tearDown() {
        sut = nil
        mockService = nil
        super.tearDown()
    }

    // MARK: - Helpers

    private static func makeEvent(id: UUID = UUID(), title: String = "Test Event") -> Event {
        Event(
            id: id,
            title: title,
            category: "Music",
            date: "March 28, 2026",
            time: "8:00 PM",
            venue: "Test Venue",
            location: "Test Location",
            price: "$25",
            description: "A test event",
            totalSpots: 100
        )
    }

    // MARK: - Load Data

    func testLoadData_fetchesEventsAndProposals() async {
        let events = [Self.makeEvent(title: "Jazz Night")]
        mockService.stubbedEvents = events
        mockService.stubbedProposals = []

        await sut.loadData()

        XCTAssertTrue(mockService.fetchAvailableEventsCalled)
        XCTAssertEqual(mockService.fetchProposalsCalls.count, 1)
        XCTAssertEqual(sut.availableEvents.count, 1)
        XCTAssertEqual(sut.availableEvents.first?.title, "Jazz Night")
        XCTAssertFalse(sut.isLoading)
    }

    func testLoadData_withError_setsErrorMessage() async {
        mockService.stubbedError = NSError(
            domain: "test",
            code: 500,
            userInfo: [NSLocalizedDescriptionKey: "Server error"]
        )

        await sut.loadData()

        XCTAssertEqual(sut.errorMessage, "Server error")
        XCTAssertFalse(sut.isLoading)
    }

    // MARK: - Propose Event

    func testProposeEvent_callsService() async {
        let event = Self.makeEvent()
        mockService.stubbedEvents = [event]

        await sut.proposeEvent(event)

        XCTAssertEqual(mockService.proposeEventCalls.count, 1)
        XCTAssertEqual(mockService.proposeEventCalls.first?.eventId, event.id)
        XCTAssertEqual(sut.proposedByMe?.id, event.id)
    }

    func testProposeEvent_withNoMatchId_doesNothing() async {
        let noMatchSut = EventAgreementViewModel(service: mockService, matchId: nil)
        let event = Self.makeEvent()

        await noMatchSut.proposeEvent(event)

        XCTAssertTrue(mockService.proposeEventCalls.isEmpty)
    }

    func testProposeEvent_withError_setsErrorMessage() async {
        mockService.stubbedError = NSError(
            domain: "test",
            code: 400,
            userInfo: [NSLocalizedDescriptionKey: "Bad request"]
        )

        await sut.proposeEvent(Self.makeEvent())

        XCTAssertEqual(sut.errorMessage, "Bad request")
    }

    // MARK: - Confirm Date

    func testConfirmDate_doesNotCrash() {
        sut.confirmDate()
        // No-op method; just verify it doesn't throw
    }

    // MARK: - Agreement Detection

    func testLoadData_withAcceptedProposal_setsAgreedEvent() async {
        let eventId = UUID()
        let event = Self.makeEvent(id: eventId, title: "Agreed Event")
        mockService.stubbedEvents = [event]
        mockService.stubbedProposals = [
            EventProposal(id: UUID(), matchId: matchId, proposerId: UUID(), eventId: eventId, status: .accepted)
        ]

        await sut.loadData()

        XCTAssertEqual(sut.agreedEvent?.id, eventId)
    }

    // MARK: - Loading State

    func testLoadData_isLoadingFalseAfterCompletion() async {
        mockService.stubbedEvents = []
        mockService.stubbedProposals = []

        await sut.loadData()

        XCTAssertFalse(sut.isLoading)
    }
}
