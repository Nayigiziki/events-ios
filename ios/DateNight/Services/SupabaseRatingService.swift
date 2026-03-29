import Foundation
import Supabase

final class SupabaseRatingService: RatingServiceProtocol, @unchecked Sendable {
    @MainActor private var client: SupabaseClient { SupabaseService.shared.client }

    private func getClient() async -> SupabaseClient {
        await MainActor.run { self.client }
    }

    nonisolated init() {}

    func currentUserId() async throws -> UUID {
        let client = await getClient()
        return try await client.auth.session.user.id
    }

    func submitRating(ratedUserId: UUID, score: Int, comment: String?) async throws -> Rating {
        // Stub: Implement Supabase insert
        Rating(id: UUID(), raterId: UUID(), ratedUserId: ratedUserId, score: score, comment: comment, createdAt: Date())
    }

    func fetchRatingsForUser(userId: UUID) async throws -> [Rating] {
        // Stub: Implement Supabase query
        []
    }

    func fetchMyRatings() async throws -> [Rating] {
        // Stub: Implement Supabase query
        []
    }
}
