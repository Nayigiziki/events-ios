@testable import DateNight
import XCTest

final class SupabaseAuthServiceIntegrationTests: XCTestCase {
    var sut: SupabaseAuthService!

    override func setUp() async throws {
        try await super.setUp()
        sut = SupabaseAuthService()
        try await IntegrationTestHelper.ensureSignedIn()
    }

    override func tearDown() async throws {
        sut = nil
        try await super.tearDown()
    }

    // MARK: - signIn

    func testSignIn_withValidCredentials_returnsSession() async throws {
        let session = try await sut.signIn(email: "quinn3@datenight.app", password: "TestPass123!")
        XCTAssertFalse(session.accessToken.isEmpty)
        XCTAssertEqual(session.user.email, "quinn3@datenight.app")
    }

    func testSignIn_withInvalidCredentials_throwsError() async {
        do {
            _ = try await sut.signIn(email: "nonexistent@datenight.app", password: "WrongPassword!")
            XCTFail("Expected sign-in to throw for invalid credentials")
        } catch {
            // Expected
        }
    }

    // MARK: - checkSession

    func testCheckSession_afterSignIn_returnsSession() async throws {
        let session = try await sut.checkSession()
        XCTAssertNotNil(session)
        XCTAssertEqual(session?.user.email, "quinn3@datenight.app")
    }

    // MARK: - signUp

    // Note: signUp is rate-limited per email; test verifies correct error handling
    // when rate-limited or when email confirmation is required.

    func testSignUp_withNewEmail_returnsSessionOrThrowsExpectedError() async throws {
        let uniqueEmail = "integration_test_\(UUID().uuidString.prefix(8))@datenight.app"
        do {
            let session = try await sut.signUp(email: uniqueEmail, password: "TestPass123!")
            XCTAssertFalse(session.accessToken.isEmpty)
        } catch let error as AuthError where error == .noSession {
            // Expected if email confirmation is required
        } catch {
            // Rate limit or other Supabase error is acceptable in CI
            let desc = error.localizedDescription
            XCTAssertTrue(
                desc.contains("rate limit") || desc.contains("over_email_send_rate_limit"),
                "Unexpected error: \(desc)"
            )
        }
        // Re-sign in as test user
        _ = try await sut.signIn(email: "quinn3@datenight.app", password: "TestPass123!")
    }
}
