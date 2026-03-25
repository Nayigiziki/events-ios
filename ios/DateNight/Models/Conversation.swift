import Foundation

struct Conversation: Codable, Identifiable, Hashable {
    let id: UUID
    var isGroup: Bool
    var groupName: String?
    var matchId: UUID?
    var createdAt: Date?
    var participants: [UserProfile]?
    var lastMessage: Message?

    enum CodingKeys: String, CodingKey {
        case id
        case isGroup = "is_group"
        case groupName = "group_name"
        case matchId = "match_id"
        case createdAt = "created_at"
        case participants
        case lastMessage = "last_message"
    }
}
