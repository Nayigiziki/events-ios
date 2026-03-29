@testable import DateNight
import XCTest

@MainActor
final class EventSwipeViewModelTests: XCTestCase {
    private var sut: EventSwipeViewModel!
    private var mockService: MockEventService!

    override func setUp() {
        super.setUp()
        mockService = MockEventService()
        sut = EventSwipeViewModel(eventService: mockService)
    }

    override func tearDown() {
        sut = nil
        mockService = nil
        super.tearDown()
    }

    // MARK: - Load Events

    func testLoadEvents_callsFetchSwipeableEvents() async {
        mockService.stubbedEvents = [Self.makeEvent(title: "Swipe Event")]

        await sut.loadEvents()

        XCTAssertEqual(mockService.fetchSwipeableEventsCalls.count, 1)
        XCTAssertEqual(sut.events.count, 1)
        XCTAssertEqual(sut.events.first?.title, "Swipe Event")
    }

    func testLoadEvents_setsIsLoading() async {
        mockService.stubbedEvents = []

        XCTAssertFalse(sut.isLoading)
        await sut.loadEvents()
        XCTAssertFalse(sut.isLoading)
    }

    func testLoadEvents_withError_setsErrorMessage() async {
        mockService.stubbedError = NSError(
            domain: "test",
            code: 500,
            userInfo: [NSLocalizedDescriptionKey: "Server error"]
        )

        await sut.loadEvents()

        XCTAssertNotNil(sut.errorMessage)
        XCTAssertTrue(sut.events.isEmpty)
    }

    // MARK: - Swipe Right (Interested)

    func testSwipeRight_advancesIndex() async {
        mockService.stubbedEvents = [Self.makeEvent(), Self.makeEvent()]
        await sut.loadEvents()

        await sut.swipeRight()

        XCTAssertEqual(sut.currentIndex, 1)
    }

    func testSwipeRight_recordsInterestedSwipe() async {
        let eventId = UUID()
        mockService.stubbedEvents = [Self.makeEvent(id: eventId)]
        await sut.loadEvents()

        await sut.swipeRight()

        XCTAssertEqual(mockService.recordSwipeCalls.count, 1)
        XCTAssertEqual(mockService.recordSwipeCalls.first?.eventId, eventId)
        XCTAssertEqual(mockService.recordSwipeCalls.first?.action, .interested)
    }

    // MARK: - Swipe Left (Skip)

    func testSwipeLeft_advancesIndex() async {
        mockService.stubbedEvents = [Self.makeEvent(), Self.makeEvent()]
        await sut.loadEvents()

        await sut.swipeLeft()

        XCTAssertEqual(sut.currentIndex, 1)
    }

    func testSwipeLeft_recordsSkipSwipe() async {
        let eventId = UUID()
        mockService.stubbedEvents = [Self.makeEvent(id: eventId)]
        await sut.loadEvents()

        await sut.swipeLeft()

        XCTAssertEqual(mockService.recordSwipeCalls.count, 1)
        XCTAssertEqual(mockService.recordSwipeCalls.first?.eventId, eventId)
        XCTAssertEqual(mockService.recordSwipeCalls.first?.action, .skip)
    }

    // MARK: - Current/Next Event

    func testCurrentEvent_returnsEventAtCurrentIndex() async {
        mockService.stubbedEvents = [Self.makeEvent(title: "First"), Self.makeEvent(title: "Second")]
        await sut.loadEvents()

        XCTAssertEqual(sut.currentEvent?.title, "First")

        await sut.swipeRight()

        XCTAssertEqual(sut.currentEvent?.title, "Second")
    }

    func testCurrentEvent_returnsNilWhenPastEnd() async {
        mockService.stubbedEvents = [Self.makeEvent()]
        await sut.loadEvents()

        await sut.swipeRight()

        XCTAssertNil(sut.currentEvent)
    }

    func testNextEvent_returnsNextEventInList() async {
        mockService.stubbedEvents = [Self.makeEvent(title: "First"), Self.makeEvent(title: "Second")]
        await sut.loadEvents()

        XCTAssertEqual(sut.nextEvent?.title, "Second")
    }

    // MARK: - Undo Swipe

    func testUndoLastSwipe_decrementsIndex() async {
        mockService.stubbedEvents = [Self.makeEvent(), Self.makeEvent()]
        await sut.loadEvents()

        await sut.swipeRight()
        XCTAssertEqual(sut.currentIndex, 1)

        sut.undoLastSwipe()
        XCTAssertEqual(sut.currentIndex, 0)
    }

    func testUndoLastSwipe_atZero_doesNothing() async {
        mockService.stubbedEvents = [Self.makeEvent()]
        await sut.loadEvents()

        sut.undoLastSwipe()
        XCTAssertEqual(sut.currentIndex, 0)
    }

    func testUndoLastSwipe_canUndoOnlyOnce() async {
        mockService.stubbedEvents = [Self.makeEvent(), Self.makeEvent(), Self.makeEvent()]
        await sut.loadEvents()

        await sut.swipeRight()
        await sut.swipeRight()
        XCTAssertEqual(sut.currentIndex, 2)

        sut.undoLastSwipe()
        XCTAssertEqual(sut.currentIndex, 1)

        // Second undo should not work — only one undo allowed
        sut.undoLastSwipe()
        XCTAssertEqual(sut.currentIndex, 1)
    }

    func testCanUndo_isTrueAfterSwipe() async {
        mockService.stubbedEvents = [Self.makeEvent(), Self.makeEvent()]
        await sut.loadEvents()

        XCTAssertFalse(sut.canUndo)

        await sut.swipeRight()
        XCTAssertTrue(sut.canUndo)
    }

    func testCanUndo_isFalseAfterUndo() async {
        mockService.stubbedEvents = [Self.makeEvent(), Self.makeEvent()]
        await sut.loadEvents()

        await sut.swipeRight()
        sut.undoLastSwipe()

        XCTAssertFalse(sut.canUndo)
    }

    // MARK: - Swipe Error Handling

    func testSwipeRight_withError_stillAdvancesIndex() async {
        mockService.stubbedEvents = [Self.makeEvent(), Self.makeEvent()]
        await sut.loadEvents()
        mockService.stubbedError = NSError(domain: "test", code: 500)

        await sut.swipeRight()

        // Optimistic: index advances even if backend fails
        XCTAssertEqual(sut.currentIndex, 1)
    }

    // MARK: - Helpers

    static func makeEvent(
        id: UUID = UUID(),
        title: String = "Test Event",
        category: String = "Music"
    ) -> Event {
        Event(
            id: id,
            title: title,
            category: category,
            date: "March 28, 2026",
            time: "8:00 PM",
            venue: "Test Venue",
            location: "Test Location",
            price: "$25",
            description: "A test event",
            totalSpots: 100
        )
    }
}
