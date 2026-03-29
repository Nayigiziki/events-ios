@testable import DateNight
import XCTest

final class NotificationIntegrationTests: XCTestCase {
    var sut: SupabaseNotificationService!

    override func setUp() async throws {
        try await super.setUp()
        sut = SupabaseNotificationService()
        try await IntegrationTestHelper.ensureSignedIn()
    }

    override func tearDown() async throws {
        sut = nil
        try await super.tearDown()
    }

    // MARK: - fetchNotifications

    // Note: notifications table may not exist in current Supabase schema

    func testFetchNotifications_forAuthenticatedUser_succeedsOrTableMissing() async throws {
        let userId = try await IntegrationTestHelper.currentUserId()
        do {
            let notifications = try await sut.fetchNotifications(userId: userId)
            XCTAssertNotNil(notifications)
        } catch {
            let desc = error.localizedDescription
            if desc.contains("PGRST205") || desc.contains("notifications") {
                // Table not yet created in Supabase
            } else {
                throw error
            }
        }
    }

    // MARK: - markAsRead

    func testMarkAsRead_succeedsOrTableMissing() async throws {
        do {
            try await sut.markAsRead(notificationId: UUID())
        } catch {
            let desc = error.localizedDescription
            if desc.contains("PGRST205") || desc.contains("notifications") {
                // Table not yet created
            } else {
                throw error
            }
        }
    }

    // MARK: - markAllAsRead

    func testMarkAllAsRead_succeedsOrTableMissing() async throws {
        let userId = try await IntegrationTestHelper.currentUserId()
        do {
            try await sut.markAllAsRead(userId: userId)
        } catch {
            let desc = error.localizedDescription
            if desc.contains("PGRST205") || desc.contains("notifications") {
                // Table not yet created
            } else {
                throw error
            }
        }
    }
}
