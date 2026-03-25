import Foundation

struct Match: Codable, Identifiable, Hashable {
    let id: UUID
    var user1Id: UUID
    var user2Id: UUID
    var eventId: UUID?
    var createdAt: Date?
    var user1: UserProfile?
    var user2: UserProfile?

    enum CodingKeys: String, CodingKey {
        case id
        case user1Id = "user1_id"
        case user2Id = "user2_id"
        case eventId = "event_id"
        case createdAt = "created_at"
        case user1
        case user2
    }
}
