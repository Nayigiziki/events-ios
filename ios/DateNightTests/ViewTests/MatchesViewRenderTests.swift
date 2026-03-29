@testable import DateNight
import SwiftUI
import XCTest

@MainActor
final class MatchesViewRenderTests: XCTestCase {
    // MARK: - MatchesView

    func testMatchesView_renders_withoutCrash() {
        let view = MatchesView()
        let hosting = renderView(view)
        XCTAssertNotNil(hosting.view)
    }
}
