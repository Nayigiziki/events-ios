import Foundation
import Supabase

@MainActor
final class AuthService: ObservableObject {
    @Published var currentUser: UserProfile?
    @Published var isAuthenticated = false

    private var client: SupabaseClient { SupabaseService.shared.client }

    func signUp(email: String, password: String, name: String, birthdate: Date?, gender: String?) async throws {
        let authResponse = try await client.auth.signUp(email: email, password: password)
        let userId = authResponse.user.id

        let profile = UserProfile(
            id: userId,
            name: name,
            gender: gender,
            birthdate: birthdate
        )

        try await client.from("profiles")
            .insert(profile)
            .execute()

        currentUser = profile
        isAuthenticated = true
    }

    func signIn(email: String, password: String) async throws {
        let session = try await client.auth.signIn(email: email, password: password)
        try await loadCurrentUser(userId: session.user.id)
        isAuthenticated = true
    }

    func signInWithGoogle() async throws {
        try await client.auth.signInWithOAuth(provider: .google)
    }

    func signInWithFacebook() async throws {
        try await client.auth.signInWithOAuth(provider: .facebook)
    }

    func signOut() async throws {
        try await client.auth.signOut()
        currentUser = nil
        isAuthenticated = false
    }

    func loadCurrentUser(userId: UUID) async throws {
        let profile: UserProfile = try await client.from("profiles")
            .select()
            .eq("id", value: userId.uuidString)
            .single()
            .execute()
            .value
        currentUser = profile
    }

    func restoreSession() async {
        do {
            let session = try await client.auth.session
            try await loadCurrentUser(userId: session.user.id)
            isAuthenticated = true
        } catch {
            isAuthenticated = false
            currentUser = nil
        }
    }

    func updateUserMetadata(_ metadata: [String: AnyJSON]) async throws {
        try await client.auth.update(user: UserAttributes(data: metadata))
    }
}
