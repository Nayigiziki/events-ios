import Foundation

struct TypingStatus: Equatable {
    let userId: UUID
    let isTyping: Bool
}

struct ConversationListItem: Identifiable, Hashable {
    let id: UUID
    let isGroup: Bool
    let groupName: String?
    let participants: [UserProfile]
    let lastMessageText: String?
    let lastMessageDate: Date?
    let unreadCount: Int
    let isTyping: Bool
}

protocol ChatServiceProtocol: Sendable {
    func fetchConversations() async throws -> [ConversationListItem]
    func fetchMessages(conversationId: UUID) async throws -> [Message]
    func sendMessage(conversationId: UUID, content: String, messageType: MessageType) async throws -> Message
    func subscribeToMessages(conversationId: UUID, onMessage: @escaping @Sendable (Message) -> Void) async
    func subscribeToConversationUpdates(onUpdate: @escaping @Sendable (ConversationListItem) -> Void) async
    func sendTypingIndicator(conversationId: UUID, isTyping: Bool) async throws
    func subscribeToTyping(conversationId: UUID, onTyping: @escaping @Sendable (TypingStatus) -> Void) async
    func unsubscribe() async
    func currentUserId() async throws -> UUID
}
