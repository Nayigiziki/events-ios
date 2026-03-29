@testable import DateNight
import SwiftUI
import XCTest

@MainActor
final class DateViewRenderTests: XCTestCase {
    // MARK: - DateDetailView

    func testDateDetailView_renders_withoutCrash() {
        let view = DateDetailView(dateRequest: TestFixtures.testDateRequest)
        let hosting = renderView(view)
        XCTAssertNotNil(hosting.view)
    }

    // MARK: - EventAgreementView

    func testEventAgreementView_renders_withoutCrash() {
        let view = EventAgreementView()
        let hosting = renderView(view)
        XCTAssertNotNil(hosting.view)
    }

    // MARK: - InviteToDateView

    func testInviteToDateView_renders_withoutCrash() {
        let view = InviteToDateView()
        let hosting = renderView(view)
        XCTAssertNotNil(hosting.view)
    }

    // MARK: - MyDatesView

    func testMyDatesView_renders_withoutCrash() {
        let view = MyDatesView()
        let hosting = renderView(view)
        XCTAssertNotNil(hosting.view)
    }
}
