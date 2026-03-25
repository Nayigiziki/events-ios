import Foundation
import Supabase

@MainActor
final class UserService {
    private var client: SupabaseClient { SupabaseService.shared.client }

    func fetchProfile(userId: UUID) async throws -> UserProfile {
        let profile: UserProfile = try await client.from("profiles")
            .select()
            .eq("id", value: userId.uuidString)
            .single()
            .execute()
            .value

        return profile
    }

    func updateProfile(_ profile: UserProfile) async throws {
        try await client.from("profiles")
            .update(profile)
            .eq("id", value: profile.id.uuidString)
            .execute()
    }

    func fetchDiscoverUsers(excludeIds: [UUID] = []) async throws -> [UserProfile] {
        let currentUserId = try await client.auth.session.user.id
        var allExcluded = excludeIds.map(\.uuidString)
        allExcluded.append(currentUserId.uuidString)

        let profiles: [UserProfile] = try await client.from("profiles")
            .select()
            .not("id", operator: .in, value: allExcluded)
            .eq("ready_to_mingle", value: true)
            .limit(20)
            .execute()
            .value

        return profiles
    }

    func searchUsers(query: String) async throws -> [UserProfile] {
        let profiles: [UserProfile] = try await client.from("profiles")
            .select()
            .ilike("name", pattern: "%\(query)%")
            .limit(20)
            .execute()
            .value

        return profiles
    }
}
