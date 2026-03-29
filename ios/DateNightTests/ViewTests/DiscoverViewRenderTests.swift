@testable import DateNight
import SwiftUI
import XCTest

@MainActor
final class DiscoverViewRenderTests: XCTestCase {
    // MARK: - UserSwipeView

    func testUserSwipeView_renders_withoutCrash() {
        let view = UserSwipeView()
        let hosting = renderView(view)
        XCTAssertNotNil(hosting.view)
    }

    // MARK: - SwipeCardView

    func testSwipeCardView_renders_withoutCrash() {
        let view = SwipeCardView(user: TestFixtures.testUser)
            .frame(width: 300, height: 400)
        let hosting = renderView(view)
        XCTAssertNotNil(hosting.view)
    }

    // MARK: - SwipeFiltersView

    func testSwipeFiltersView_renders_withoutCrash() {
        let view = SwipeFiltersView(
            showFilters: .constant(true),
            filters: .constant(DiscoverFilters())
        )
        let hosting = renderView(view)
        XCTAssertNotNil(hosting.view)
    }

    // MARK: - MatchDetailView

    func testMatchDetailView_renders_withoutCrash() {
        let matchedUser = TestFixtures.testUser
        let vm = MatchDetailViewModel(matchedUser: matchedUser)
        let view = MatchDetailView(
            viewModel: vm,
            currentUser: TestFixtures.testUser,
            onSendMessage: {},
            onKeepSwiping: {}
        )
        let hosting = renderView(view)
        XCTAssertNotNil(hosting.view)
    }
}
