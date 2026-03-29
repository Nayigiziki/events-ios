import Foundation

@MainActor
final class NotificationsViewModel: ObservableObject {
    @Published var notifications: [AppNotification] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
    }

    private let notificationService: any NotificationServiceProtocol
    private let userId: UUID

    init(notificationService: any NotificationServiceProtocol = SupabaseNotificationService(), userId: UUID = UUID()) {
        self.notificationService = notificationService
        self.userId = userId
    }

    func loadNotifications() async {
        isLoading = true
        errorMessage = nil
        do {
            notifications = try await notificationService.fetchNotifications(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func markAsRead(_ notificationId: UUID) async {
        if let index = notifications.firstIndex(where: { $0.id == notificationId }) {
            notifications[index].isRead = true
        }
        do {
            try await notificationService.markAsRead(notificationId: notificationId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func markAllAsRead() async {
        for index in notifications.indices {
            notifications[index].isRead = true
        }
        do {
            try await notificationService.markAllAsRead(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
