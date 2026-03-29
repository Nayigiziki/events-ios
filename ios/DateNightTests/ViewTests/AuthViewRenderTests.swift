@testable import DateNight
import SwiftUI
import XCTest

@MainActor
final class AuthViewRenderTests: XCTestCase {
    // MARK: - LoginView

    func testLoginView_renders_withoutCrash() {
        let authVM = TestFixtures.makeAuthViewModel()
        let view = LoginView().environmentObject(authVM)
        let hosting = renderView(view)
        XCTAssertNotNil(hosting.view)
    }

    // MARK: - SignUpView

    func testSignUpView_renders_withoutCrash() {
        let authVM = TestFixtures.makeAuthViewModel()
        let view = NavigationStack { SignUpView().environmentObject(authVM) }
        let hosting = renderView(view)
        XCTAssertNotNil(hosting.view)
    }

    // MARK: - ForgotPasswordView

    func testForgotPasswordView_renders_withoutCrash() {
        let view = NavigationStack { ForgotPasswordView() }
        let hosting = renderView(view)
        XCTAssertNotNil(hosting.view)
    }

    // MARK: - ContentView

    func testContentView_renders_withoutCrash() {
        let view = ContentView()
        let hosting = renderView(view)
        XCTAssertNotNil(hosting.view)
    }

    // MARK: - OnboardingView

    func testOnboardingView_renders_withoutCrash() {
        let authVM = TestFixtures.makeAuthViewModel()
        let view = OnboardingView().environmentObject(authVM)
        let hosting = renderView(view)
        XCTAssertNotNil(hosting.view)
    }
}
