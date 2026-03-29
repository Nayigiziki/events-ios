import Foundation
import Supabase

final class SupabaseAuthService: AuthServiceProtocol {
    private var client: SupabaseClient { SupabaseService.shared.client }

    func signIn(email: String, password: String) async throws -> AuthSession {
        let session = try await client.auth.signIn(email: email, password: password)
        return AuthSession(
            user: AuthUser(id: session.user.id, email: session.user.email ?? ""),
            accessToken: session.accessToken
        )
    }

    func signUp(email: String, password: String) async throws -> AuthSession {
        let response = try await client.auth.signUp(email: email, password: password)
        guard let session = response.session else {
            throw AuthError.noSession
        }
        return AuthSession(
            user: AuthUser(id: session.user.id, email: session.user.email ?? ""),
            accessToken: session.accessToken
        )
    }

    func signOut() async throws {
        try await client.auth.signOut()
    }

    func checkSession() async throws -> AuthSession? {
        do {
            let session = try await client.auth.session
            return AuthSession(
                user: AuthUser(id: session.user.id, email: session.user.email ?? ""),
                accessToken: session.accessToken
            )
        } catch {
            return nil
        }
    }

    func signInWithGoogle() async throws -> AuthSession {
        // OAuth requires URL callback handling; returns a placeholder for now
        try await client.auth.signInWithOAuth(provider: .google)
        let session = try await client.auth.session
        return AuthSession(
            user: AuthUser(id: session.user.id, email: session.user.email ?? ""),
            accessToken: session.accessToken
        )
    }

    func signInWithFacebook() async throws -> AuthSession {
        try await client.auth.signInWithOAuth(provider: .facebook)
        let session = try await client.auth.session
        return AuthSession(
            user: AuthUser(id: session.user.id, email: session.user.email ?? ""),
            accessToken: session.accessToken
        )
    }
}

enum AuthError: LocalizedError {
    case noSession

    var errorDescription: String? {
        switch self {
        case .noSession:
            "No session was created. Please check your email for confirmation."
        }
    }
}
