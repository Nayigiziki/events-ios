import Foundation
import Supabase

final class ProfileService: ProfileServiceProtocol, @unchecked Sendable {
    @MainActor private var client: SupabaseClient { SupabaseService.shared.client }

    private func getClient() async -> SupabaseClient {
        await MainActor.run { self.client }
    }

    nonisolated init() {}

    func fetchProfile(userId: UUID) async throws -> UserProfile {
        let client = await getClient()
        let profile: UserProfile = try await client.from("profiles")
            .select()
            .eq("id", value: userId.uuidString)
            .single()
            .execute()
            .value
        return profile
    }

    func updateProfile(_ request: ProfileUpdateRequest, userId: UUID) async throws {
        let client = await getClient()
        try await client.from("profiles")
            .update(request)
            .eq("id", value: userId.uuidString)
            .execute()
    }

    func fetchStats(userId: UUID) async throws -> ProfileStats {
        let client = await getClient()
        let userIdStr = userId.uuidString

        let matches: [Match] = try await client.from("matches")
            .select()
            .or("user1_id.eq.\(userIdStr),user2_id.eq.\(userIdStr)")
            .execute()
            .value

        let dates: [[String: String]] = try await client.from("date_requests")
            .select("id")
            .or("sender_id.eq.\(userIdStr),receiver_id.eq.\(userIdStr)")
            .eq("status", value: "accepted")
            .execute()
            .value

        let events: [[String: String]] = try await client.from("event_likes")
            .select("id")
            .eq("user_id", value: userIdStr)
            .execute()
            .value

        return ProfileStats(matches: matches.count, dates: dates.count, events: events.count)
    }

    func fetchActivity(userId: UUID) async throws -> [Activity] {
        let client = await getClient()
        let userIdStr = userId.uuidString

        let recentMatches: [Match] = try await client.from("matches")
            .select("*, user1:profiles!user1_id(name), user2:profiles!user2_id(name)")
            .or("user1_id.eq.\(userIdStr),user2_id.eq.\(userIdStr)")
            .order("created_at", ascending: false)
            .limit(5)
            .execute()
            .value

        var activities: [Activity] = []
        for (index, match) in recentMatches.prefix(3).enumerated() {
            activities.append(Activity(
                id: "match-\(index)",
                icon: "heart.fill",
                iconColor: "pink",
                title: "New match!",
                subtitle: match.eventId != nil ? "Via event" : "Direct match",
                timeAgo: "recent"
            ))
        }

        return activities
    }

    func uploadPhoto(data: Data, userId: UUID) async throws -> String {
        let path = "profiles/\(userId.uuidString)/\(UUID().uuidString).jpg"
        let storageService = await MainActor.run { StorageService() }
        return try await storageService.uploadPhoto(data: data, path: path)
    }

    func deleteAccount() async throws {
        let client = await getClient()
        let userId = try await client.auth.session.user.id

        try await client.from("profiles")
            .delete()
            .eq("id", value: userId.uuidString)
            .execute()

        try await client.auth.signOut()
    }
}
