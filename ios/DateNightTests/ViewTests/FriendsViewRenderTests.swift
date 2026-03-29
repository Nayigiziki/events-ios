@testable import DateNight
import SwiftUI
import XCTest

@MainActor
final class FriendsViewRenderTests: XCTestCase {
    // MARK: - FriendsListView

    func testFriendsListView_renders_withoutCrash() {
        let view = FriendsListView()
        let hosting = renderView(view)
        XCTAssertNotNil(hosting.view)
    }

    // MARK: - AddFriendsView

    func testAddFriendsView_renders_withoutCrash() {
        let vm = FriendsViewModel()
        let view = NavigationStack {
            AddFriendsView(friendsViewModel: vm)
        }
        let hosting = renderView(view)
        XCTAssertNotNil(hosting.view)
    }
}
