import Foundation
import Supabase

final class SupabaseFriendService: FriendServiceProtocol, @unchecked Sendable {
    @MainActor private var client: SupabaseClient { SupabaseService.shared.client }

    private func getClient() async -> SupabaseClient {
        await MainActor.run { self.client }
    }

    nonisolated init() {}

    func currentUserId() async throws -> UUID {
        let client = await getClient()
        return try await client.auth.session.user.id
    }

    func fetchFriends() async throws -> [UserProfile] {
        // Stub: Implement Supabase query
        []
    }

    func fetchFriendRequests() async throws -> [FriendRelationship] {
        // Stub: Implement Supabase query
        []
    }

    func sendFriendRequest(toUserId: UUID) async throws -> FriendRelationship {
        // Stub: Implement Supabase insert
        FriendRelationship(id: UUID(), userId: UUID(), friendId: toUserId, status: .pending, createdAt: Date())
    }

    func acceptFriendRequest(requestId: UUID) async throws {
        // Stub: Implement Supabase update
    }

    func declineFriendRequest(requestId: UUID) async throws {
        // Stub: Implement Supabase update
    }

    func removeFriend(friendId: UUID) async throws {
        // Stub: Implement Supabase delete
    }

    func searchUsers(query: String) async throws -> [UserProfile] {
        // Stub: Implement Supabase query
        []
    }
}
