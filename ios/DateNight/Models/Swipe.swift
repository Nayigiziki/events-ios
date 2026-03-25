import Foundation

struct Swipe: Codable, Identifiable, Hashable {
    let id: UUID
    var swiperId: UUID
    var swipedId: UUID
    var direction: SwipeDirection
    var eventId: UUID?
    var createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case swiperId = "swiper_id"
        case swipedId = "swiped_id"
        case direction
        case eventId = "event_id"
        case createdAt = "created_at"
    }
}

enum SwipeDirection: String, Codable, Hashable {
    case left
    case right
}
