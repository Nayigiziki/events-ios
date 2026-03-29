import Foundation

struct AppNotification: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let type: String
    let title: String
    let subtitle: String
    var isRead: Bool
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case type
        case title
        case subtitle
        case isRead = "is_read"
        case createdAt = "created_at"
    }
}

protocol NotificationServiceProtocol: Sendable {
    func fetchNotifications(userId: UUID) async throws -> [AppNotification]
    func markAsRead(notificationId: UUID) async throws
    func markAllAsRead(userId: UUID) async throws
}
