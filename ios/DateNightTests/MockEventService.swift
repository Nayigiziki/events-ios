@testable import DateNight
import Foundation

final class MockEventService: EventServiceProtocol, @unchecked Sendable {
    // MARK: - Stubs

    var stubbedEvents: [Event] = []
    var stubbedEvent: Event?
    var stubbedComments: [EventComment] = []
    var stubbedComment: EventComment?
    var stubbedImageUrl: String = "https://example.com/image.jpg"
    var stubbedLikedEventIds: [UUID] = []
    var stubbedLikedEventIdsError: Error?
    var stubbedError: Error?

    // MARK: - Call tracking

    // swiftlint:disable large_tuple
    var fetchEventsCalls: [(category: String?, limit: Int, offset: Int)] = []
    var searchEventsCalls: [(query: String, limit: Int, offset: Int)] = []
    // swiftlint:enable large_tuple
    var likeEventCalls: [UUID] = []
    var unlikeEventCalls: [UUID] = []
    var createEventCalls: [EventCreateRequest] = []
    var deleteEventCalls: [UUID] = []
    var updateEventCalls: [(UUID, EventCreateRequest)] = []
    var recordSwipeCalls: [EventSwipeAction] = []
    var rsvpEventCalls: [UUID] = []
    var rsvpEventCallCount: Int { rsvpEventCalls.count }
    var unrsvpEventCalls: [UUID] = []
    var unrsvpEventCallCount: Int { unrsvpEventCalls.count }
    var addCommentCalls: [EventCommentCreateRequest] = []
    var deleteCommentCalls: [UUID] = []
    var voteCommentCalls: [CommentVoteRequest] = []
    var createDateCalls: [DateCreateRequest] = []
    var uploadImageCalls: [Data] = []
    var fetchLikedEventIdsCalled = false
    var fetchSwipeableEventsCalls: [(limit: Int, offset: Int)] = []
    var fetchMyCreatedEventsCalled = false
    var fetchMyAttendingEventsCalled = false

    // MARK: - EventServiceProtocol

    func fetchEvents(category: String?, limit: Int, offset: Int) async throws -> [Event] {
        if let error = stubbedError { throw error }
        fetchEventsCalls.append((category, limit, offset))
        return stubbedEvents
    }

    func fetchEventDetail(id: UUID) async throws -> Event {
        if let error = stubbedError { throw error }
        guard let event = stubbedEvent ?? stubbedEvents.first(where: { $0.id == id }) else {
            throw NSError(
                domain: "MockEventService",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "Event not found"]
            )
        }
        return event
    }

    func searchEvents(query: String, limit: Int, offset: Int) async throws -> [Event] {
        if let error = stubbedError { throw error }
        searchEventsCalls.append((query, limit, offset))
        return stubbedEvents
    }

    func fetchLikedEventIds() async throws -> [UUID] {
        if let error = stubbedLikedEventIdsError { throw error }
        fetchLikedEventIdsCalled = true
        return stubbedLikedEventIds
    }

    func likeEvent(_ eventId: UUID) async throws {
        if let error = stubbedError { throw error }
        likeEventCalls.append(eventId)
    }

    func unlikeEvent(_ eventId: UUID) async throws {
        if let error = stubbedError { throw error }
        unlikeEventCalls.append(eventId)
    }

    func createEvent(_ request: EventCreateRequest) async throws -> Event {
        if let error = stubbedError { throw error }
        createEventCalls.append(request)
        return stubbedEvent ?? Event(
            title: request.title,
            category: request.category,
            date: request.date,
            time: request.time,
            venue: request.venue,
            location: request.location,
            price: request.price,
            description: request.description,
            totalSpots: request.totalSpots,
            isPublic: request.isPublic
        )
    }

    func deleteEvent(_ eventId: UUID) async throws {
        if let error = stubbedError { throw error }
        deleteEventCalls.append(eventId)
    }

    func updateEvent(_ eventId: UUID, _ request: EventCreateRequest) async throws -> Event {
        if let error = stubbedError { throw error }
        updateEventCalls.append((eventId, request))
        return stubbedEvent ?? Event(
            title: request.title,
            category: request.category,
            date: request.date,
            time: request.time,
            venue: request.venue,
            location: request.location,
            price: request.price,
            description: request.description,
            totalSpots: request.totalSpots,
            isPublic: request.isPublic
        )
    }

    func fetchMyCreatedEvents() async throws -> [Event] {
        if let error = stubbedError { throw error }
        fetchMyCreatedEventsCalled = true
        return stubbedEvents
    }

    func fetchMyAttendingEvents() async throws -> [Event] {
        if let error = stubbedError { throw error }
        fetchMyAttendingEventsCalled = true
        return stubbedEvents
    }

    func recordSwipe(_ action: EventSwipeAction) async throws {
        if let error = stubbedError { throw error }
        recordSwipeCalls.append(action)
    }

    func fetchSwipeableEvents(limit: Int, offset: Int) async throws -> [Event] {
        if let error = stubbedError { throw error }
        fetchSwipeableEventsCalls.append((limit, offset))
        return stubbedEvents
    }

    func rsvpEvent(_ eventId: UUID) async throws {
        if let error = stubbedError { throw error }
        rsvpEventCalls.append(eventId)
    }

    func unrsvpEvent(_ eventId: UUID) async throws {
        if let error = stubbedError { throw error }
        unrsvpEventCalls.append(eventId)
    }

    func fetchComments(eventId: UUID) async throws -> [EventComment] {
        if let error = stubbedError { throw error }
        return stubbedComments
    }

    func addComment(_ request: EventCommentCreateRequest) async throws -> EventComment {
        if let error = stubbedError { throw error }
        addCommentCalls.append(request)
        return stubbedComment ?? EventComment(
            userName: "Test User",
            text: request.text,
            timestamp: "Just now"
        )
    }

    func deleteComment(_ commentId: UUID) async throws {
        if let error = stubbedError { throw error }
        deleteCommentCalls.append(commentId)
    }

    func voteComment(_ request: CommentVoteRequest) async throws {
        if let error = stubbedError { throw error }
        voteCommentCalls.append(request)
    }

    func createDate(_ request: DateCreateRequest) async throws {
        if let error = stubbedError { throw error }
        createDateCalls.append(request)
    }

    func uploadEventImage(_ imageData: Data) async throws -> String {
        if let error = stubbedError { throw error }
        uploadImageCalls.append(imageData)
        return stubbedImageUrl
    }
}
