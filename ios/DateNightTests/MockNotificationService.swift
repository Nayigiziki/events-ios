@testable import DateNight
import Foundation

final class MockNotificationService: NotificationServiceProtocol, @unchecked Sendable {
    var fetchCallCount = 0
    var markAsReadCallCount = 0
    var markAllAsReadCallCount = 0
    var lastMarkedId: UUID?
    var shouldFail = false

    var stubbedNotifications: [AppNotification] = []

    func fetchNotifications(userId: UUID) async throws -> [AppNotification] {
        fetchCallCount += 1
        if shouldFail {
            throw NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Fetch failed"])
        }
        return stubbedNotifications
    }

    func markAsRead(notificationId: UUID) async throws {
        markAsReadCallCount += 1
        lastMarkedId = notificationId
        if shouldFail {
            throw NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mark failed"])
        }
    }

    func markAllAsRead(userId: UUID) async throws {
        markAllAsReadCallCount += 1
        if shouldFail {
            throw NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mark all failed"])
        }
    }
}
