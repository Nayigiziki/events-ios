@testable import DateNight
import SwiftData
import SwiftUI
import XCTest

@MainActor
final class ChatViewSwiftDataRenderTests: XCTestCase {
    // MARK: - ChatView (SwiftData-backed)

    func testChatView_renders_withoutCrash() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ChatMessage.self, configurations: config)
        let claudeService = ClaudeService()

        let view = NavigationStack {
            ChatView()
                .environmentObject(claudeService)
                .modelContainer(container)
        }
        let hosting = renderView(view)
        XCTAssertNotNil(hosting.view)
    }
}
