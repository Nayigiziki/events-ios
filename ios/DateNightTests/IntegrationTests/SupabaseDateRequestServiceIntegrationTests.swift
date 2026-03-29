@testable import DateNight
import XCTest

final class DateRequestIntegrationTests: XCTestCase {
    var sut: SupabaseDateRequestService!
    var eventService: SupabaseEventService!

    override func setUp() async throws {
        try await super.setUp()
        sut = SupabaseDateRequestService()
        eventService = SupabaseEventService()
        try await IntegrationTestHelper.ensureSignedIn()
    }

    override func tearDown() async throws {
        sut = nil
        eventService = nil
        try await super.tearDown()
    }

    // MARK: - fetchAvailableDates

    func testFetchAvailableDates_returnsArray() async throws {
        let dates = try await sut.fetchAvailableDates()
        XCTAssertNotNil(dates)
    }

    // MARK: - createDateRequest / fetchMyDates

    func testCreateDateRequest_andFetchMyDates() async throws {
        let eventRequest = EventCreateRequest(
            title: "Date Request Test Event",
            category: "Music",
            imageUrl: nil,
            date: "2026-12-31",
            time: "20:00",
            venue: "DR Venue",
            location: "DR City",
            price: "Free",
            description: "Event for date request test",
            totalSpots: 10,
            isPublic: true
        )
        let event = try await eventService.createEvent(eventRequest)

        try await sut.createDateRequest(
            eventId: event.id,
            maxPeople: 4,
            description: "Integration test date request",
            dateType: .group
        )

        let myDates = try await sut.fetchMyDates(status: nil)
        let created = myDates.first(where: { $0.eventId == event.id })
        XCTAssertNotNil(created)
        XCTAssertEqual(created?.description, "Integration test date request")
        XCTAssertEqual(created?.dateType, .group)

        // Clean up
        if let dateRequest = created {
            try await sut.cancelDate(requestId: dateRequest.id)
        }
        try await eventService.deleteEvent(event.id)
    }

    // MARK: - joinDate / leaveDate

    func testJoinDate_andLeaveDate() async throws {
        let eventRequest = EventCreateRequest(
            title: "Join Test Event",
            category: "Food",
            imageUrl: nil,
            date: "2026-12-31",
            time: "19:00",
            venue: "Join Venue",
            location: "Join City",
            price: "Free",
            description: "Event for join/leave test",
            totalSpots: 10,
            isPublic: true
        )
        let event = try await eventService.createEvent(eventRequest)

        try await sut.createDateRequest(
            eventId: event.id,
            maxPeople: 4,
            description: "Join test date request",
            dateType: .solo
        )

        let myDates = try await sut.fetchMyDates(status: nil)
        guard let dateRequest = myDates.first(where: { $0.eventId == event.id }) else {
            XCTFail("Could not find created date request")
            return
        }

        try await sut.joinDate(requestId: dateRequest.id)
        try await sut.leaveDate(requestId: dateRequest.id)

        // Clean up
        try await sut.cancelDate(requestId: dateRequest.id)
        try await eventService.deleteEvent(event.id)
    }
}
