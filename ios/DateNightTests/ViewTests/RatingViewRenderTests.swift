@testable import DateNight
import SwiftUI
import XCTest

@MainActor
final class RatingViewRenderTests: XCTestCase {
    // MARK: - RateMatchView

    func testRateMatchView_renders_withoutCrash() {
        let view = RateMatchView(ratedUser: TestFixtures.testUser)
        let hosting = renderView(view)
        XCTAssertNotNil(hosting.view)
    }

    // MARK: - MyReviewsView

    func testMyReviewsView_renders_withoutCrash() {
        let view = MyReviewsView()
        let hosting = renderView(view)
        XCTAssertNotNil(hosting.view)
    }
}
