import Foundation
import Supabase

final class SupabaseNotificationService: NotificationServiceProtocol, @unchecked Sendable {
    @MainActor private var client: SupabaseClient { SupabaseService.shared.client }

    nonisolated init() {}

    func fetchNotifications(userId: UUID) async throws -> [AppNotification] {
        let client = await MainActor.run { self.client }
        return try await client.from("notifications")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    func markAsRead(notificationId: UUID) async throws {
        let client = await MainActor.run { self.client }
        try await client.from("notifications")
            .update(["is_read": true])
            .eq("id", value: notificationId.uuidString)
            .execute()
    }

    func markAllAsRead(userId: UUID) async throws {
        let client = await MainActor.run { self.client }
        try await client.from("notifications")
            .update(["is_read": true])
            .eq("user_id", value: userId.uuidString)
            .eq("is_read", value: false)
            .execute()
    }
}
