@testable import DateNight
import SwiftUI
import XCTest

@MainActor
final class SettingsViewRenderTests: XCTestCase {
    // MARK: - SettingsView

    func testSettingsView_renders_withoutCrash() {
        let authVM = TestFixtures.makeAuthViewModel()
        let view = NavigationStack {
            SettingsView().environmentObject(authVM)
        }
        let hosting = renderView(view)
        XCTAssertNotNil(hosting.view)
    }

    // MARK: - ChangePasswordView

    func testChangePasswordView_renders_withoutCrash() {
        let view = ChangePasswordView()
        let hosting = renderView(view)
        XCTAssertNotNil(hosting.view)
    }

    // MARK: - EmailSettingsView

    func testEmailSettingsView_renders_withoutCrash() {
        let view = EmailSettingsView()
        let hosting = renderView(view)
        XCTAssertNotNil(hosting.view)
    }

    // MARK: - HelpCenterView

    func testHelpCenterView_renders_withoutCrash() {
        let view = HelpCenterView()
        let hosting = renderView(view)
        XCTAssertNotNil(hosting.view)
    }

    // MARK: - HelpSupportView

    func testHelpSupportView_renders_withoutCrash() {
        let view = NavigationStack { HelpSupportView() }
        let hosting = renderView(view)
        XCTAssertNotNil(hosting.view)
    }

    // MARK: - PrivacyPolicyView

    func testPrivacyPolicyView_renders_withoutCrash() {
        let view = PrivacyPolicyView()
        let hosting = renderView(view)
        XCTAssertNotNil(hosting.view)
    }

    // MARK: - ReportProblemView

    func testReportProblemView_renders_withoutCrash() {
        let view = ReportProblemView()
        let hosting = renderView(view)
        XCTAssertNotNil(hosting.view)
    }

    // MARK: - TermsView

    func testTermsView_renders_withoutCrash() {
        let view = TermsView()
        let hosting = renderView(view)
        XCTAssertNotNil(hosting.view)
    }
}
