@testable import DateNight
import XCTest

@MainActor
final class AddEventViewModelTests: XCTestCase {
    private var sut: AddEventViewModel!
    private var mockService: MockEventService!

    override func setUp() {
        super.setUp()
        mockService = MockEventService()
        sut = AddEventViewModel(eventService: mockService)
    }

    override func tearDown() {
        sut = nil
        mockService = nil
        super.tearDown()
    }

    // MARK: - Validation

    func testIsValid_emptyTitle_returnsFalse() {
        sut.title = ""
        sut.venue = "Test Venue"

        XCTAssertFalse(sut.isValid)
    }

    func testIsValid_emptyVenue_returnsFalse() {
        sut.title = "Test Event"
        sut.venue = ""

        XCTAssertFalse(sut.isValid)
    }

    func testIsValid_titleAndVenueProvided_returnsTrue() {
        sut.title = "Test Event"
        sut.venue = "Test Venue"

        XCTAssertTrue(sut.isValid)
    }

    // MARK: - Create Event

    func testCreateEvent_callsServiceWithCorrectFields() async {
        sut.title = "My Event"
        sut.description = "Great event"
        sut.selectedCategory = "Music"
        sut.venue = "Cool Venue"
        sut.location = "Downtown"
        sut.price = "$25"
        sut.isPublic = true

        await sut.createEvent()

        XCTAssertEqual(mockService.createEventCalls.count, 1)
        let request = mockService.createEventCalls.first
        XCTAssertEqual(request?.title, "My Event")
        XCTAssertEqual(request?.description, "Great event")
        XCTAssertEqual(request?.category, "Music")
        XCTAssertEqual(request?.venue, "Cool Venue")
        XCTAssertEqual(request?.location, "Downtown")
        XCTAssertEqual(request?.price, "$25")
        XCTAssertEqual(request?.isPublic, true)
    }

    func testCreateEvent_setsDidCreateOnSuccess() async {
        sut.title = "Test Event"
        sut.venue = "Test Venue"

        XCTAssertFalse(sut.didCreate)

        await sut.createEvent()

        XCTAssertTrue(sut.didCreate)
    }

    func testCreateEvent_setsIsCreatingDuringCall() async {
        sut.title = "Test Event"
        sut.venue = "Test Venue"

        XCTAssertFalse(sut.isCreating)
        await sut.createEvent()
        XCTAssertFalse(sut.isCreating)
    }

    func testCreateEvent_withError_setsErrorMessage() async {
        sut.title = "Test Event"
        sut.venue = "Test Venue"
        mockService.stubbedError = NSError(
            domain: "test",
            code: 500,
            userInfo: [NSLocalizedDescriptionKey: "Server error"]
        )

        await sut.createEvent()

        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.didCreate)
    }

    func testCreateEvent_invalidForm_doesNotCallService() async {
        sut.title = ""
        sut.venue = ""

        await sut.createEvent()

        XCTAssertTrue(mockService.createEventCalls.isEmpty)
        XCTAssertFalse(sut.didCreate)
    }

    // MARK: - Image Upload

    func testCreateEvent_withImage_uploadsAndSetsImageUrl() async {
        sut.title = "Test Event"
        sut.venue = "Test Venue"
        sut.selectedImage = UIImage(systemName: "star")

        mockService.stubbedImageUrl = "https://example.com/uploaded.jpg"

        await sut.createEvent()

        XCTAssertEqual(mockService.uploadImageCalls.count, 1)
        XCTAssertEqual(mockService.createEventCalls.first?.imageUrl, "https://example.com/uploaded.jpg")
    }

    func testCreateEvent_withoutImage_noUpload() async {
        sut.title = "Test Event"
        sut.venue = "Test Venue"
        sut.selectedImage = nil

        await sut.createEvent()

        XCTAssertTrue(mockService.uploadImageCalls.isEmpty)
        XCTAssertNil(mockService.createEventCalls.first?.imageUrl)
    }

    // MARK: - Total Spots

    func testCreateEvent_customTotalSpots() async {
        sut.title = "Test Event"
        sut.venue = "Test Venue"
        sut.totalSpots = "50"

        await sut.createEvent()

        XCTAssertEqual(mockService.createEventCalls.first?.totalSpots, 50)
    }

    func testCreateEvent_invalidTotalSpots_defaultsTo100() async {
        sut.title = "Test Event"
        sut.venue = "Test Venue"
        sut.totalSpots = "not a number"

        await sut.createEvent()

        XCTAssertEqual(mockService.createEventCalls.first?.totalSpots, 100)
    }

    // MARK: - Default Values

    func testCreateEvent_emptyLocation_usesVenue() async {
        sut.title = "Test Event"
        sut.venue = "My Venue"
        sut.location = ""

        await sut.createEvent()

        XCTAssertEqual(mockService.createEventCalls.first?.location, "My Venue")
    }

    func testCreateEvent_emptyPrice_setsFree() async {
        sut.title = "Test Event"
        sut.venue = "Test Venue"
        sut.price = ""

        await sut.createEvent()

        XCTAssertEqual(mockService.createEventCalls.first?.price, "Free")
    }

    // MARK: - Editing Mode

    func testInit_withEvent_prefillsFields() {
        let event = Event(
            title: "Existing Event",
            category: "Art",
            date: "April 15, 2026",
            time: "7:00 PM",
            venue: "Gallery",
            location: "Midtown",
            price: "$10",
            description: "Art show",
            totalSpots: 50,
            isPublic: false
        )

        let editSut = AddEventViewModel(eventService: mockService, event: event)

        XCTAssertTrue(editSut.isEditing)
        XCTAssertEqual(editSut.title, "Existing Event")
        XCTAssertEqual(editSut.selectedCategory, "Art")
        XCTAssertEqual(editSut.venue, "Gallery")
        XCTAssertEqual(editSut.location, "Midtown")
        XCTAssertEqual(editSut.price, "$10")
        XCTAssertEqual(editSut.description, "Art show")
        XCTAssertEqual(editSut.totalSpots, "50")
        XCTAssertFalse(editSut.isPublic)
    }

    func testInit_withoutEvent_isNotEditing() {
        XCTAssertFalse(sut.isEditing)
    }

    func testSave_inEditMode_callsUpdateEvent() async {
        let event = Event(
            title: "Existing",
            category: "Music",
            date: "April 15, 2026",
            time: "7:00 PM",
            venue: "Venue",
            location: "Here",
            price: "Free",
            description: "Desc",
            totalSpots: 40,
            isPublic: true
        )

        let editSut = AddEventViewModel(eventService: mockService, event: event)
        editSut.title = "Updated Title"
        editSut.venue = "New Venue"

        await editSut.save()

        XCTAssertTrue(mockService.createEventCalls.isEmpty)
        XCTAssertEqual(mockService.updateEventCalls.count, 1)
        XCTAssertEqual(mockService.updateEventCalls.first?.0, event.id)
        XCTAssertEqual(mockService.updateEventCalls.first?.1.title, "Updated Title")
        XCTAssertTrue(editSut.didCreate)
    }

    func testSave_inCreateMode_callsCreateEvent() async {
        sut.title = "New Event"
        sut.venue = "Venue"

        await sut.save()

        XCTAssertEqual(mockService.createEventCalls.count, 1)
        XCTAssertTrue(mockService.updateEventCalls.isEmpty)
    }
}
