@testable import DateNight
import SwiftUI
import XCTest

@MainActor
final class NotificationsViewRenderTests: XCTestCase {
    // MARK: - NotificationsView

    func testNotificationsView_renders_withoutCrash() {
        let view = NotificationsView()
        let hosting = renderView(view)
        XCTAssertNotNil(hosting.view)
    }
}
