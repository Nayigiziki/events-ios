import Foundation
import Supabase

final class SupabaseReportService: ReportServiceProtocol, @unchecked Sendable {
    @MainActor private var client: SupabaseClient { SupabaseService.shared.client }

    nonisolated init() {}

    func submitReport(reportedUserId: UUID, reason: String, details: String) async throws {
        let client = await MainActor.run { self.client }
        let reporterId = try await client.auth.session.user.id

        try await client.from("reports").insert([
            "reporter_id": reporterId.uuidString,
            "reported_user_id": reportedUserId.uuidString,
            "reason": reason,
            "details": details
        ]).execute()
    }

    func blockUser(userId: UUID) async throws {
        let client = await MainActor.run { self.client }
        let blockerId = try await client.auth.session.user.id

        try await client.from("blocked_users").insert([
            "blocker_id": blockerId.uuidString,
            "blocked_user_id": userId.uuidString
        ]).execute()
    }
}
