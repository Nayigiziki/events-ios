import Foundation
import Supabase

final class SupabaseReviewService: ReviewServiceProtocol, @unchecked Sendable {
    @MainActor private var client: SupabaseClient { SupabaseService.shared.client }

    nonisolated init() {}

    func fetchReviews(forUserId userId: UUID) async throws -> [DateReview] {
        let client = await MainActor.run { self.client }
        return try await client.from("reviews")
            .select("*, reviewer:profiles!reviewer_id(*)")
            .eq("reviewed_user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value
    }
}
