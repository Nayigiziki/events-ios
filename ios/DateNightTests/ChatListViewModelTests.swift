@testable import DateNight
import XCTest

@MainActor
final class ChatListViewModelTests: XCTestCase {
    private var sut: ChatListViewModel!
    private var mockService: MockChatService!

    override func setUp() {
        super.setUp()
        mockService = MockChatService()
        sut = ChatListViewModel(chatService: mockService)
    }

    override func tearDown() {
        sut = nil
        mockService = nil
        super.tearDown()
    }

    // MARK: - Initial State

    func testInitialState_conversationsEmpty() {
        XCTAssertTrue(sut.conversations.isEmpty)
        XCTAssertTrue(sut.searchText.isEmpty)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }

    // MARK: - Fetch Conversations

    func testLoadConversations_success_populatesConversations() async {
        let items = [
            makeConversationItem(id: UUID(), lastMessage: "Hello"),
            makeConversationItem(id: UUID(), lastMessage: "World")
        ]
        mockService.fetchConversationsResult = .success(items)

        await sut.loadConversations()

        XCTAssertEqual(sut.conversations.count, 2)
        XCTAssertEqual(mockService.fetchConversationsCallCount, 1)
        XCTAssertFalse(sut.isLoading)
    }

    func testLoadConversations_failure_setsErrorMessage() async {
        mockService.fetchConversationsResult = .failure(NSError(domain: "test", code: 1))

        await sut.loadConversations()

        XCTAssertTrue(sut.conversations.isEmpty)
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
    }

    // MARK: - Search Filtering

    func testFilteredConversations_emptySearch_returnsAll() async {
        let items = [
            makeConversationItem(id: UUID(), groupName: "Jazz Night", isGroup: true),
            makeConversationItem(id: UUID(), participantName: "Emma")
        ]
        mockService.fetchConversationsResult = .success(items)
        await sut.loadConversations()

        sut.searchText = ""

        XCTAssertEqual(sut.filteredConversations.count, 2)
    }

    func testFilteredConversations_matchesGroupName() async {
        let items = [
            makeConversationItem(id: UUID(), groupName: "Jazz Night", isGroup: true),
            makeConversationItem(id: UUID(), participantName: "Emma")
        ]
        mockService.fetchConversationsResult = .success(items)
        await sut.loadConversations()

        sut.searchText = "Jazz"

        XCTAssertEqual(sut.filteredConversations.count, 1)
        XCTAssertEqual(sut.filteredConversations.first?.groupName, "Jazz Night")
    }

    func testFilteredConversations_matchesParticipantName() async {
        let items = [
            makeConversationItem(id: UUID(), participantName: "Emma"),
            makeConversationItem(id: UUID(), participantName: "Sarah")
        ]
        mockService.fetchConversationsResult = .success(items)
        await sut.loadConversations()

        sut.searchText = "emma"

        XCTAssertEqual(sut.filteredConversations.count, 1)
    }

    func testFilteredConversations_matchesLastMessageContent() async {
        let items = [
            makeConversationItem(id: UUID(), lastMessage: "Concert tonight!"),
            makeConversationItem(id: UUID(), lastMessage: "See you later")
        ]
        mockService.fetchConversationsResult = .success(items)
        await sut.loadConversations()

        sut.searchText = "concert"

        XCTAssertEqual(sut.filteredConversations.count, 1)
    }

    // MARK: - Realtime Updates

    func testSubscribesToConversationUpdates() async {
        await sut.loadConversations()

        XCTAssertEqual(mockService.subscribeToConversationUpdatesCallCount, 1)
    }

    func testRealtimeUpdate_updatesExistingConversation() async {
        let conversationId = UUID()
        let items = [makeConversationItem(id: conversationId, lastMessage: "Old message")]
        mockService.fetchConversationsResult = .success(items)
        await sut.loadConversations()

        let updated = makeConversationItem(id: conversationId, lastMessage: "New message")
        mockService.simulateConversationUpdate(updated)

        // Give MainActor time to process
        await Task.yield()

        XCTAssertEqual(sut.conversations.first?.lastMessageText, "New message")
    }

    func testRealtimeUpdate_addsNewConversation() async {
        mockService.fetchConversationsResult = .success([])
        await sut.loadConversations()

        let newItem = makeConversationItem(id: UUID(), lastMessage: "Hey!")
        mockService.simulateConversationUpdate(newItem)

        await Task.yield()

        XCTAssertEqual(sut.conversations.count, 1)
    }

    // MARK: - Helpers

    private func makeConversationItem(
        id: UUID,
        groupName: String? = nil,
        isGroup: Bool = false,
        participantName: String = "User",
        lastMessage: String? = nil
    ) -> ConversationListItem {
        ConversationListItem(
            id: id,
            isGroup: isGroup,
            groupName: groupName,
            participants: [
                UserProfile(id: UUID(), name: participantName)
            ],
            lastMessageText: lastMessage,
            lastMessageDate: Date(),
            unreadCount: 0,
            isTyping: false
        )
    }
}
