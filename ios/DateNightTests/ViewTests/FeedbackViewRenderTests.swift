@testable import DateNight
import SwiftUI
import XCTest

@MainActor
final class FeedbackViewRenderTests: XCTestCase {
    // MARK: - FeedbackChatView

    func testFeedbackChatView_renders_withoutCrash() {
        let view = FeedbackChatView()
        let hosting = renderView(view)
        XCTAssertNotNil(hosting.view)
    }
}
