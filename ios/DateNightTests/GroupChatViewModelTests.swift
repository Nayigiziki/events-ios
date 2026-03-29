@testable import DateNight
import XCTest

@MainActor
final class GroupChatViewModelTests: XCTestCase {
    private var sut: GroupChatViewModel!
    private var mockService: MockChatService!
    private let conversationId = UUID()
    private let currentUserId = UUID()

    override func setUp() {
        super.setUp()
        mockService = MockChatService()
        mockService.currentUserIdResult = .success(currentUserId)
        sut = GroupChatViewModel(
            conversationId: conversationId,
            groupName: "Jazz Night",
            chatService: mockService
        )
    }

    override func tearDown() {
        sut = nil
        mockService = nil
        super.tearDown()
    }

    // MARK: - Initial State

    func testInitialState() {
        XCTAssertTrue(sut.messages.isEmpty)
        XCTAssertTrue(sut.participants.isEmpty)
        XCTAssertEqual(sut.groupName, "Jazz Night")
        XCTAssertTrue(sut.messageText.isEmpty)
        XCTAssertFalse(sut.showParticipants)
    }

    // MARK: - Load Messages

    func testLoadMessages_success_populatesMessages() async {
        let messages = [
            makeMessage(content: "Hello group!"),
            makeMessage(content: "Welcome everyone")
        ]
        mockService.fetchMessagesResult = .success(messages)

        await sut.loadMessages()

        XCTAssertEqual(sut.messages.count, 2)
        XCTAssertEqual(mockService.fetchMessagesCallCount, 1)
        XCTAssertFalse(sut.isLoading)
    }

    func testLoadMessages_failure_setsErrorMessage() async {
        mockService.fetchMessagesResult = .failure(NSError(domain: "test", code: 1))

        await sut.loadMessages()

        XCTAssertTrue(sut.messages.isEmpty)
        XCTAssertNotNil(sut.errorMessage)
    }

    func testLoadMessages_subscribesToRealtimeMessages() async {
        await sut.loadMessages()

        XCTAssertEqual(mockService.subscribeToMessagesCallCount, 1)
    }

    // MARK: - Send Message

    func testSendMessage_success_clearsTextField() async {
        sut.messageText = "Hello group!"

        await sut.sendMessage()

        XCTAssertEqual(sut.messageText, "")
        XCTAssertEqual(mockService.sendMessageCallCount, 1)
        XCTAssertEqual(mockService.lastSentContent, "Hello group!")
        XCTAssertEqual(mockService.lastSentConversationId, conversationId)
    }

    func testSendMessage_emptyText_doesNothing() async {
        sut.messageText = "  "

        await sut.sendMessage()

        XCTAssertEqual(mockService.sendMessageCallCount, 0)
    }

    // MARK: - Realtime Incoming Messages

    func testIncomingMessage_appendsToMessages() async {
        await sut.loadMessages()

        let incoming = makeMessage(content: "New group message!")
        mockService.simulateIncomingMessage(incoming)

        await Task.yield()

        XCTAssertTrue(sut.messages.contains(where: { $0.content == "New group message!" }))
    }

    func testIncomingMessage_doesNotDuplicate() async {
        let existing = makeMessage(content: "Existing")
        mockService.fetchMessagesResult = .success([existing])
        await sut.loadMessages()

        mockService.simulateIncomingMessage(existing)

        await Task.yield()

        XCTAssertEqual(sut.messages.filter { $0.id == existing.id }.count, 1)
    }

    // MARK: - Current User

    func testCurrentUserId_isLoaded() async {
        await sut.loadMessages()

        XCTAssertEqual(sut.currentUserId, currentUserId)
    }

    // MARK: - Helpers

    private func makeMessage(content: String) -> Message {
        Message(
            id: UUID(),
            conversationId: conversationId,
            senderId: UUID(),
            content: content,
            messageType: .text,
            createdAt: Date()
        )
    }
}
