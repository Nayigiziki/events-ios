@testable import DateNight
import SwiftUI
import XCTest

@MainActor
final class FeedViewRenderTests: XCTestCase {
    // MARK: - FeedView

    func testFeedView_renders_withoutCrash() {
        let view = NavigationStack { FeedView() }
        let hosting = renderView(view)
        XCTAssertNotNil(hosting.view)
    }

    // MARK: - EventCardView

    func testEventCardView_renders_withoutCrash() {
        let view = NavigationStack {
            EventCardView(
                event: TestFixtures.testEvent,
                isLiked: false,
                onToggleLike: {}
            )
        }
        let hosting = renderView(view)
        XCTAssertNotNil(hosting.view)
    }

    func testEventCardView_liked_renders_withoutCrash() {
        let view = NavigationStack {
            EventCardView(
                event: TestFixtures.testEvent,
                isLiked: true,
                onToggleLike: {}
            )
        }
        let hosting = renderView(view)
        XCTAssertNotNil(hosting.view)
    }
}
