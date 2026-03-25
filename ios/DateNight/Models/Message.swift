import Foundation

struct Message: Codable, Identifiable, Hashable {
    let id: UUID
    var conversationId: UUID
    var senderId: UUID
    var content: String
    var messageType: MessageType
    var createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case conversationId = "conversation_id"
        case senderId = "sender_id"
        case content
        case messageType = "message_type"
        case createdAt = "created_at"
    }
}

enum MessageType: String, Codable, Hashable {
    case text
    case image
    case location
}
