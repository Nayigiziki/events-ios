import Foundation

struct EventCreateRequest: Codable {
    let title: String
    let category: String
    let imageUrl: String?
    let date: String
    let time: String
    let venue: String
    let location: String
    let price: String
    let description: String
    let totalSpots: Int
    let isPublic: Bool

    enum CodingKeys: String, CodingKey {
        case title, category, date, time, venue, location, price, description
        case imageUrl = "image_url"
        case totalSpots = "total_spots"
        case isPublic = "is_public"
    }
}

struct EventSwipeAction: Codable {
    let eventId: UUID
    let action: SwipeActionType

    enum SwipeActionType: String, Codable {
        case interested
        case skip
    }

    enum CodingKeys: String, CodingKey {
        case eventId = "event_id"
        case action
    }
}

struct EventCommentCreateRequest {
    let eventId: UUID
    let text: String
}

struct CommentVoteRequest {
    let commentId: UUID
    let direction: EventComment.VoteDirection
}

struct DateCreateRequest {
    let eventId: UUID
    let dateType: String
    let groupSize: Int
    let description: String
    let invitedUserIds: [UUID]
}

protocol EventServiceProtocol: Sendable {
    func fetchEvents(category: String?, limit: Int, offset: Int) async throws -> [Event]
    func fetchEventDetail(id: UUID) async throws -> Event
    func searchEvents(query: String, limit: Int, offset: Int) async throws -> [Event]
    func fetchLikedEventIds() async throws -> [UUID]
    func likeEvent(_ eventId: UUID) async throws
    func unlikeEvent(_ eventId: UUID) async throws
    func createEvent(_ request: EventCreateRequest) async throws -> Event
    func deleteEvent(_ eventId: UUID) async throws
    func updateEvent(_ eventId: UUID, _ request: EventCreateRequest) async throws -> Event
    func fetchMyCreatedEvents() async throws -> [Event]
    func fetchMyAttendingEvents() async throws -> [Event]
    func recordSwipe(_ action: EventSwipeAction) async throws
    func fetchSwipeableEvents(limit: Int, offset: Int) async throws -> [Event]
    func rsvpEvent(_ eventId: UUID) async throws
    func unrsvpEvent(_ eventId: UUID) async throws
    func fetchComments(eventId: UUID) async throws -> [EventComment]
    func addComment(_ request: EventCommentCreateRequest) async throws -> EventComment
    func deleteComment(_ commentId: UUID) async throws
    func voteComment(_ request: CommentVoteRequest) async throws
    func createDate(_ request: DateCreateRequest) async throws
    func uploadEventImage(_ imageData: Data) async throws -> String
}
