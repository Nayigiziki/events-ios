@testable import DateNight
import XCTest

@MainActor
final class FeedViewModelTests: XCTestCase {
    private var sut: FeedViewModel!
    private var mockService: MockEventService!

    override func setUp() {
        super.setUp()
        mockService = MockEventService()
        sut = FeedViewModel(eventService: mockService)
    }

    override func tearDown() {
        sut = nil
        mockService = nil
        super.tearDown()
    }

    // MARK: - Fetch Events

    func testLoadEvents_callsServiceWithNilCategory() async {
        mockService.stubbedEvents = [Self.makeEvent(title: "Test Event")]

        await sut.loadEvents()

        XCTAssertEqual(mockService.fetchEventsCalls.count, 1)
        XCTAssertNil(mockService.fetchEventsCalls.first?.category)
    }

    func testLoadEvents_populatesEventsArray() async {
        let events = [Self.makeEvent(title: "Event 1"), Self.makeEvent(title: "Event 2")]
        mockService.stubbedEvents = events

        await sut.loadEvents()

        XCTAssertEqual(sut.events.count, 2)
        XCTAssertEqual(sut.events[0].title, "Event 1")
        XCTAssertEqual(sut.events[1].title, "Event 2")
    }

    func testLoadEvents_setsIsLoadingDuringFetch() async {
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

    // MARK: - Category Filtering

    func testSelectCategory_fetchesWithCategory() async {
        mockService.stubbedEvents = []

        sut.selectedCategory = "Music"
        await sut.loadEvents()

        XCTAssertEqual(mockService.fetchEventsCalls.last?.category, "Music")
    }

    func testSelectCategory_all_fetchesWithNilCategory() async {
        mockService.stubbedEvents = []

        sut.selectedCategory = "All"
        await sut.loadEvents()

        XCTAssertNil(mockService.fetchEventsCalls.last?.category)
    }

    func testFilteredEvents_returnsAllWhenCategoryIsAll() async {
        mockService.stubbedEvents = [
            Self.makeEvent(title: "Music Event", category: "Music"),
            Self.makeEvent(title: "Art Event", category: "Art")
        ]

        sut.selectedCategory = "All"
        await sut.loadEvents()

        XCTAssertEqual(sut.filteredEvents.count, 2)
    }

    // MARK: - Like/Unlike

    func testToggleLike_likesUnlikedEvent() async {
        let eventId = UUID()

        await sut.toggleLike(eventId: eventId)

        XCTAssertEqual(mockService.likeEventCalls.count, 1)
        XCTAssertEqual(mockService.likeEventCalls.first, eventId)
        XCTAssertTrue(sut.likedEventIds.contains(eventId))
    }

    func testToggleLike_unlikesLikedEvent() async {
        let eventId = UUID()
        sut.likedEventIds.insert(eventId)

        await sut.toggleLike(eventId: eventId)

        XCTAssertEqual(mockService.unlikeEventCalls.count, 1)
        XCTAssertEqual(mockService.unlikeEventCalls.first, eventId)
        XCTAssertFalse(sut.likedEventIds.contains(eventId))
    }

    func testToggleLike_withError_revertsState() async {
        let eventId = UUID()
        mockService.stubbedError = NSError(domain: "test", code: 500)

        await sut.toggleLike(eventId: eventId)

        XCTAssertFalse(sut.likedEventIds.contains(eventId))
    }

    // MARK: - Load Liked Event IDs

    func testLoadEvents_alsoLoadsLikedEventIds() async {
        let likedId1 = UUID()
        let likedId2 = UUID()
        mockService.stubbedEvents = [Self.makeEvent(title: "Event 1")]
        mockService.stubbedLikedEventIds = [likedId1, likedId2]

        await sut.loadEvents()

        XCTAssertTrue(mockService.fetchLikedEventIdsCalled)
        XCTAssertEqual(sut.likedEventIds, [likedId1, likedId2])
    }

    func testLoadEvents_likedIdsError_doesNotCrash() async {
        mockService.stubbedEvents = [Self.makeEvent(title: "Event 1")]
        mockService.stubbedLikedEventIdsError = NSError(domain: "test", code: 500)

        await sut.loadEvents()

        // Events still load even if liked IDs fail
        XCTAssertEqual(sut.events.count, 1)
        XCTAssertTrue(sut.likedEventIds.isEmpty)
    }

    // MARK: - Pagination

    func testLoadMore_appendsEvents() async {
        // First page must be full (pageSize=20) so hasMorePages stays true
        mockService.stubbedEvents = (0 ..< 20).map { Self.makeEvent(title: "Event \($0)") }
        await sut.loadEvents()
        XCTAssertEqual(sut.events.count, 20)
        XCTAssertTrue(sut.hasMorePages)

        mockService.stubbedEvents = [Self.makeEvent(title: "Page 2")]
        await sut.loadMore()

        XCTAssertEqual(sut.events.count, 21)
        XCTAssertEqual(sut.events[20].title, "Page 2")
    }

    func testLoadMore_passesCorrectOffset() async {
        mockService.stubbedEvents = (0 ..< 20).map { _ in Self.makeEvent() }
        await sut.loadEvents()

        mockService.stubbedEvents = []
        await sut.loadMore()

        XCTAssertEqual(mockService.fetchEventsCalls.last?.offset, 20)
    }

    func testLoadMore_setsHasMorePagesFalse_whenLessThanPageSize() async {
        mockService.stubbedEvents = [Self.makeEvent()]
        await sut.loadEvents()

        // Got fewer than pageSize (20), so no more pages
        XCTAssertFalse(sut.hasMorePages)
    }

    func testLoadMore_doesNotFetch_whenNoMorePages() async {
        mockService.stubbedEvents = [Self.makeEvent()]
        await sut.loadEvents()
        let callCount = mockService.fetchEventsCalls.count

        await sut.loadMore()

        XCTAssertEqual(mockService.fetchEventsCalls.count, callCount)
    }

    // MARK: - Search

    func testSearch_callsSearchService() async {
        mockService.stubbedEvents = [Self.makeEvent(title: "Found Event")]
        sut.searchText = "Found"

        await sut.searchEvents()

        XCTAssertEqual(mockService.searchEventsCalls.count, 1)
        XCTAssertEqual(mockService.searchEventsCalls.first?.query, "Found")
        XCTAssertEqual(sut.events.count, 1)
    }

    func testSearch_emptyQuery_loadsRegularEvents() async {
        mockService.stubbedEvents = [Self.makeEvent(title: "All Events")]
        sut.searchText = ""

        await sut.searchEvents()

        // Should call fetchEvents, not searchEvents
        XCTAssertTrue(mockService.searchEventsCalls.isEmpty)
        XCTAssertEqual(mockService.fetchEventsCalls.count, 1)
    }

    // MARK: - Empty State

    func testIsEmpty_trueWhenNoEvents() async {
        mockService.stubbedEvents = []
        await sut.loadEvents()

        XCTAssertTrue(sut.isEmpty)
    }

    func testIsEmpty_falseWhenEventsExist() async {
        mockService.stubbedEvents = [Self.makeEvent()]
        await sut.loadEvents()

        XCTAssertFalse(sut.isEmpty)
    }

    // MARK: - Refresh

    func testRefresh_reloadsEvents() async {
        mockService.stubbedEvents = [Self.makeEvent(title: "Fresh Event")]

        await sut.refresh()

        XCTAssertEqual(sut.events.count, 1)
        XCTAssertEqual(sut.events.first?.title, "Fresh Event")
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
