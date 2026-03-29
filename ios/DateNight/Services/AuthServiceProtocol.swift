import Foundation

struct AuthUser {
    let id: UUID
    let email: String
}

struct AuthSession {
    let user: AuthUser
    let accessToken: String
}

protocol AuthServiceProtocol: Sendable {
    func signIn(email: String, password: String) async throws -> AuthSession
    func signUp(email: String, password: String) async throws -> AuthSession
    func signOut() async throws
    func checkSession() async throws -> AuthSession?
    func signInWithGoogle() async throws -> AuthSession
    func signInWithFacebook() async throws -> AuthSession
}
