@testable import DateNight
import SwiftUI
import XCTest

@MainActor
final class SafetyViewRenderTests: XCTestCase {
    // MARK: - ReportUserView

    func testReportUserView_renders_withoutCrash() {
        let view = ReportUserView(reportedUser: TestFixtures.testUser)
        let hosting = renderView(view)
        XCTAssertNotNil(hosting.view)
    }
}
