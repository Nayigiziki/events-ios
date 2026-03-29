@testable import DateNight
import XCTest

@MainActor
final class MyEventsViewModelTests: XCTestCase {
    private var mockService: MockEventService!
    private var sut: MyEventsViewModel!

    private func makeEvent(title: String) -> Event {
        Event(
            title: title,
            category: "Music",
            date: "April 10, 2026",
            time: "8:00 PM",
            venue: "Sky Lounge",
            location: "Downtown",
            price: "$30",
            description: "Test event",
            totalSpots: 40
        )
    }

    override func setUp() {
        super.setUp()
        mockService = MockEventService()
        sut = MyEventsViewModel(eventService: mockService)
    }

    // MARK: - Load Events

    func testLoadEvents_fetchesBothCreatedAndAttending() async {
        let created = [makeEvent(title: "My Event")]
        let attending = [makeEvent(title: "Other Event")]
        mockService.stubbedEvents = created

        await sut.loadEvents()

        XCTAssertTrue(mockService.fetchMyCreatedEventsCalled)
        XCTAssertTrue(mockService.fetchMyAttendingEventsCalled)
        XCTAssertFalse(sut.isLoading)
    }

    func testLoadEvents_onError_setsErrorMessage() async {
        mockService.stubbedError = NSError(
            domain: "test",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "Network error"]
        )

        await sut.loadEvents()

        XCTAssertEqual(sut.errorMessage, "Network error")
        XCTAssertFalse(sut.isLoading)
    }

    // MARK: - Delete Event

    func testDeleteEvent_callsServiceAndRemovesFromList() async {
        let event = makeEvent(title: "To Delete")
        sut.createdEvents = [event]

        await sut.deleteEvent(event)

        XCTAssertEqual(mockService.deleteEventCalls, [event.id])
        XCTAssertTrue(sut.createdEvents.isEmpty)
    }

    func testDeleteEvent_onError_setsErrorMessage() async {
        mockService.stubbedError = NSError(
            domain: "test",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "Delete failed"]
        )
        let event = makeEvent(title: "To Delete")
        sut.createdEvents = [event]

        await sut.deleteEvent(event)

        XCTAssertEqual(sut.errorMessage, "Delete failed")
    }

    // MARK: - Tab Selection

    func testInitialTab_isCreated() {
        XCTAssertEqual(sut.selectedTab, .created)
    }
}
