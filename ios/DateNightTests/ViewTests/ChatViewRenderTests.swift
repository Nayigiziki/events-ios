@testable import DateNight
import SwiftUI
import XCTest

@MainActor
final class ChatViewRenderTests: XCTestCase {
    // MARK: - ChatListView

    func testChatListView_renders_withoutCrash() {
        let view = ChatListView()
        let hosting = renderView(view)
        XCTAssertNotNil(hosting.view)
    }

    // MARK: - ConversationChatView

    func testConversationChatView_renders_withoutCrash() {
        let view = NavigationStack {
            ConversationChatView(
                conversationId: UUID(),
                partner: TestFixtures.testUser
            )
        }
        let hosting = renderView(view)
        XCTAssertNotNil(hosting.view)
    }

    // MARK: - GroupChatView

    func testGroupChatView_renders_withoutCrash() {
        let view = NavigationStack {
            GroupChatView(
                conversationId: UUID(),
                groupName: "Test Group"
            )
        }
        let hosting = renderView(view)
        XCTAssertNotNil(hosting.view)
    }

    // MARK: - MessageBubbleView

    func testMessageBubbleView_sentMessage_renders_withoutCrash() {
        let view = MessageBubbleView(
            message: TestFixtures.testMessage,
            isSent: true
        )
        let hosting = renderView(view)
        XCTAssertNotNil(hosting.view)
    }

    func testMessageBubbleView_receivedMessage_renders_withoutCrash() {
        let view = MessageBubbleView(
            message: TestFixtures.testMessage,
            isSent: false
        )
        let hosting = renderView(view)
        XCTAssertNotNil(hosting.view)
    }
}
