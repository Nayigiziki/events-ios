@testable import DateNight
import SwiftUI
import XCTest

@MainActor
final class ProfileViewRenderTests: XCTestCase {
    // MARK: - ProfileView

    func testProfileView_renders_withoutCrash() {
        let authVM = TestFixtures.makeAuthViewModel()
        let view = ProfileView(
            profileService: MockProfileService(),
            userId: UUID()
        ).environmentObject(authVM)
        let hosting = renderView(view)
        XCTAssertNotNil(hosting.view)
    }

    // MARK: - ProfileEditView

    func testProfileEditView_renders_withoutCrash() {
        let view = NavigationStack { ProfileEditView() }
        let hosting = renderView(view)
        XCTAssertNotNil(hosting.view)
    }

    // MARK: - ProfileSetupView

    func testProfileSetupView_renders_withoutCrash() {
        let authVM = TestFixtures.makeAuthViewModel()
        let view = ProfileSetupView().environmentObject(authVM)
        let hosting = renderView(view)
        XCTAssertNotNil(hosting.view)
    }

    // MARK: - MatchPreferencesView

    func testMatchPreferencesView_renders_withoutCrash() {
        let view = NavigationStack { MatchPreferencesView() }
        let hosting = renderView(view)
        XCTAssertNotNil(hosting.view)
    }
}
