@testable import DateNight
import XCTest

/// Shared helper that signs in once for all integration tests to avoid Supabase rate limits.
enum IntegrationTestHelper {
    private static var isSignedIn = false
    private static let lock = NSLock()

    /// Ensures the test user is signed in. Safe to call from multiple test classes.
    static func ensureSignedIn() async throws {
        lock.lock()
        let alreadySignedIn = isSignedIn
        lock.unlock()

        if alreadySignedIn { return }

        let authService = SupabaseAuthService()
        // Check if we already have a valid session
        if let session = try await authService.checkSession(), !session.accessToken.isEmpty {
            lock.lock()
            isSignedIn = true
            lock.unlock()
            return
        }

        _ = try await authService.signIn(email: "quinn3@datenight.app", password: "TestPass123!")
        lock.lock()
        isSignedIn = true
        lock.unlock()
    }

    static func currentUserId() async throws -> UUID {
        try await SupabaseService.shared.client.auth.session.user.id
    }
}
