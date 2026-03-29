import Foundation
import Supabase

final class SupabaseInviteService: InviteServiceProtocol, @unchecked Sendable {
    private var client: SupabaseClient { SupabaseService.shared.client }

    func fetchMatches() async throws -> [UserProfile] {
        let userId = try await client.auth.session.user.id

        let matches: [Match] = try await client.from("matches")
            .select("*, user1:profiles!user1_id(*), user2:profiles!user2_id(*)")
            .or("user1_id.eq.\(userId.uuidString),user2_id.eq.\(userId.uuidString)")
            .execute()
            .value

        return matches.compactMap { match in
            match.user1Id == userId ? match.user2 : match.user1
        }
    }

    func fetchFriends() async throws -> [UserProfile] {
        // Friends are derived from matches for now
        try await fetchMatches()
    }

    func sendInvitations(dateRequestId: UUID, userIds: [UUID]) async throws {
        let rows = userIds.map { userId in
            [
                "date_request_id": dateRequestId.uuidString,
                "invited_user_id": userId.uuidString
            ]
        }
        try await client.from("date_invitations")
            .insert(rows)
            .execute()
    }
}
