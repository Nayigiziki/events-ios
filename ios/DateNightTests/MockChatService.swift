@testable import DateNight
import Foundation

final class MockChatService: ChatServiceProtocol, @unchecked Sendable {
    // MARK: - Stubs

    var fetchConversationsResult: Result<[ConversationListItem], Error> = .success([])
    var fetchMessagesResult: Result<[Message], Error> = .success([])
    var sendMessageResult: Result<Message, Error> = .success(
        Message(
            id: UUID(),
            conversationId: UUID(),
            senderId: UUID(),
            content: "sent",
            messageType: .text,
            createdAt: Date()
        )
    )
    var currentUserIdResult: Result<UUID, Error> = .success(UUID())

    // MARK: - Call Tracking

    var fetchConversationsCallCount = 0
    var fetchMessagesCallCount = 0
    var sendMessageCallCount = 0
    var lastSentContent: String?
    var lastSentConversationId: UUID?
    var subscribeToMessagesCallCount = 0
    var subscribeToConversationUpdatesCallCount = 0
    var sendTypingIndicatorCallCount = 0
    var lastTypingState: Bool?
    var subscribeToTypingCallCount = 0
    var unsubscribeCallCount = 0

    // MARK: - Callbacks for triggering from tests

    var onMessageCallback: ((Message) -> Void)?
    var onConversationUpdateCallback: ((ConversationListItem) -> Void)?
    var onTypingCallback: ((TypingStatus) -> Void)?

    // MARK: - Protocol

    func fetchConversations() async throws -> [ConversationListItem] {
        fetchConversationsCallCount += 1
        return try fetchConversationsResult.get()
    }

    func fetchMessages(conversationId: UUID) async throws -> [Message] {
        fetchMessagesCallCount += 1
        return try fetchMessagesResult.get()
    }

    func sendMessage(conversationId: UUID, content: String, messageType: MessageType) async throws -> Message {
        sendMessageCallCount += 1
        lastSentContent = content
        lastSentConversationId = conversationId
        return try sendMessageResult.get()
    }

    func subscribeToMessages(conversationId: UUID, onMessage: @escaping @Sendable (Message) -> Void) async {
        subscribeToMessagesCallCount += 1
        onMessageCallback = onMessage
    }

    func subscribeToConversationUpdates(onUpdate: @escaping @Sendable (ConversationListItem) -> Void) async {
        subscribeToConversationUpdatesCallCount += 1
        onConversationUpdateCallback = onUpdate
    }

    func sendTypingIndicator(conversationId: UUID, isTyping: Bool) async throws {
        sendTypingIndicatorCallCount += 1
        lastTypingState = isTyping
    }

    func subscribeToTyping(conversationId: UUID, onTyping: @escaping @Sendable (TypingStatus) -> Void) async {
        subscribeToTypingCallCount += 1
        onTypingCallback = onTyping
    }

    func unsubscribe() async {
        unsubscribeCallCount += 1
    }

    func currentUserId() async throws -> UUID {
        try currentUserIdResult.get()
    }

    // MARK: - Test Helpers

    func simulateIncomingMessage(_ message: Message) {
        onMessageCallback?(message)
    }

    func simulateConversationUpdate(_ item: ConversationListItem) {
        onConversationUpdateCallback?(item)
    }

    func simulateTyping(_ status: TypingStatus) {
        onTypingCallback?(status)
    }
}
