@testable import DateNight
import Foundation

final class MockAuthService: AuthServiceProtocol, @unchecked Sendable {
    var signInResult: Result<AuthSession, Error> = .success(
        AuthSession(user: AuthUser(id: UUID(), email: "test@test.com"), accessToken: "token")
    )
    var signUpResult: Result<AuthSession, Error> = .success(
        AuthSession(user: AuthUser(id: UUID(), email: "test@test.com"), accessToken: "token")
    )
    var signOutError: Error?
    var checkSessionResult: AuthSession?
    var signInWithGoogleResult: Result<AuthSession, Error> = .success(
        AuthSession(user: AuthUser(id: UUID(), email: "test@test.com"), accessToken: "token")
    )
    var signInWithFacebookResult: Result<AuthSession, Error> = .success(
        AuthSession(user: AuthUser(id: UUID(), email: "test@test.com"), accessToken: "token")
    )

    var signInCallCount = 0
    var signUpCallCount = 0
    var signOutCallCount = 0
    var checkSessionCallCount = 0

    func signIn(email: String, password: String) async throws -> AuthSession {
        signInCallCount += 1
        return try signInResult.get()
    }

    func signUp(email: String, password: String) async throws -> AuthSession {
        signUpCallCount += 1
        return try signUpResult.get()
    }

    func signOut() async throws {
        signOutCallCount += 1
        if let error = signOutError {
            throw error
        }
    }

    func checkSession() async throws -> AuthSession? {
        checkSessionCallCount += 1
        return checkSessionResult
    }

    func signInWithGoogle() async throws -> AuthSession {
        try signInWithGoogleResult.get()
    }

    func signInWithFacebook() async throws -> AuthSession {
        try signInWithFacebookResult.get()
    }
}
