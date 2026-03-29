@testable import DateNight
import SwiftUI
import XCTest

@MainActor
final class NavigationViewRenderTests: XCTestCase {
    // MARK: - MainTabView

    func testMainTabView_renders_withoutCrash() {
        let authVM = TestFixtures.makeAuthViewModel()
        let view = MainTabView().environmentObject(authVM)
        let hosting = renderView(view)
        XCTAssertNotNil(hosting.view)
    }
}
