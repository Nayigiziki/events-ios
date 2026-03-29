import Foundation
import Supabase

final class SupabaseDiscoverService: DiscoverServiceProtocol, @unchecked Sendable {
    private var client: SupabaseClient { SupabaseService.shared.client }

    func fetchNearbyUsers(filters: DiscoverFilters) async throws -> [UserProfile] {
        let currentUserId = try await client.auth.session.user.id

        var query = client.from("profiles")
            .select()
            .neq("id", value: currentUserId.uuidString)
            .eq("ready_to_mingle", value: true)

        if let gender = filters.genderPreference {
            query = query.eq("gender", value: gender)
        }

        let profiles: [UserProfile] = try await query
            .limit(20)
            .execute()
            .value

        // Client-side filter for age (server doesn't store age directly, it's computed from birthdate)
        return profiles.filter { profile in
            if let age = profile.age {
                return age >= filters.minAge && age <= filters.maxAge
            }
            return true
        }
    }

    func recordSwipe(userId: UUID, direction: SwipeDirection) async throws -> SwipeResult {
        let currentUserId = try await client.auth.session.user.id

        // Record the swipe
        try await client.from("swipes")
            .insert([
                "swiper_id": currentUserId.uuidString,
                "swiped_id": userId.uuidString,
                "direction": direction.rawValue
            ])
            .execute()

        // If it was a right swipe, check for mutual match
        if direction == .right {
            let mutualSwipes: [Swipe] = try await client.from("swipes")
                .select()
                .eq("swiper_id", value: userId.uuidString)
                .eq("swiped_id", value: currentUserId.uuidString)
                .eq("direction", value: SwipeDirection.right.rawValue)
                .execute()
                .value

            if !mutualSwipes.isEmpty {
                // Create match
                let matchId = UUID()
                try await client.from("matches")
                    .insert([
                        "id": matchId.uuidString,
                        "user1_id": currentUserId.uuidString,
                        "user2_id": userId.uuidString
                    ])
                    .execute()

                let match = Match(id: matchId, user1Id: currentUserId, user2Id: userId)
                return .matched(match)
            }
        }

        return .recorded
    }

    func checkMutualMatch(userId: UUID) async throws -> Bool {
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
