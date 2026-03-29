import Foundation
import Supabase

final class SupabaseChatService: ChatServiceProtocol, @unchecked Sendable {
    private var client: SupabaseClient { SupabaseService.shared.client }

    func fetchConversations() async throws -> [ConversationListItem] { [] }
    func fetchMessages(conversationId: UUID) async throws -> [Message] { [] }
    func sendMessage(conversationId: UUID, content: String, messageType: MessageType) async throws -> Message {
        fatalError("Not yet implemented")
    }

    func subscribeToMessages(conversationId: UUID, onMessage: @escaping @Sendable (Message) -> Void) async {}
    func subscribeToConversationUpdates(onUpdate: @escaping @Sendable (ConversationListItem) -> Void) async {}
    func sendTypingIndicator(conversationId: UUID, isTyping: Bool) async throws {}
    func subscribeToTyping(conversationId: UUID, onTyping: @escaping @Sendable (TypingStatus) -> Void) async {}
    func unsubscribe() async {}
    func currentUserId() async throws -> UUID {
        try await client.auth.session.user.id
    }
}
