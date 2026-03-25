import Foundation
import Supabase

@MainActor
final class MatchService {
    private var client: SupabaseClient { SupabaseService.shared.client }

    func recordSwipe(swipedId: UUID, direction: SwipeDirection, eventId: UUID? = nil) async throws {
        let userId = try await client.auth.session.user.id

        var values: [String: String] = [
            "swiper_id": userId.uuidString,
            "swiped_id": swipedId.uuidString,
            "direction": direction.rawValue
        ]

        if let eventId {
            values["event_id"] = eventId.uuidString
        }

        try await client.from("swipes")
            .insert(values)
            .execute()
    }

    func fetchMatches() async throws -> [Match] {
        let userId = try await client.auth.session.user.id

        let matches: [Match] = try await client.from("matches")
            .select("*, user1:profiles!user1_id(*), user2:profiles!user2_id(*)")
            .or("user1_id.eq.\(userId.uuidString),user2_id.eq.\(userId.uuidString)")
            .order("created_at", ascending: false)
            .execute()
            .value

        return matches
    }

    func checkForMatch(userId: UUID) async throws -> Bool {
        let currentUserId = try await client.auth.session.user.id

        let matches: [Match] = try await client.from("matches")
            .select()
            .or(
                "and(user1_id.eq.\(currentUserId.uuidString),user2_id.eq.\(userId.uuidString)),and(user1_id.eq.\(userId.uuidString),user2_id.eq.\(currentUserId.uuidString))"
            )
            .execute()
            .value

        return !matches.isEmpty
    }
}
