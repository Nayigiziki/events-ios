@testable import DateNight
import XCTest

@MainActor
final class NotificationsViewModelTests: XCTestCase {
    private var mockService: MockNotificationService!
    private var sut: NotificationsViewModel!
    private let testUserId = UUID()

    private func makeNotification(id: UUID = UUID(), isRead: Bool = false) -> AppNotification {
        AppNotification(
            id: id,
            userId: testUserId,
            type: "match",
            title: "Test",
            subtitle: "Test subtitle",
            isRead: isRead,
            createdAt: Date()
        )
    }

    override func setUp() {
        super.setUp()
        mockService = MockNotificationService()
        sut = NotificationsViewModel(notificationService: mockService, userId: testUserId)
    }

    func testLoadNotificationsFetchesFromService() async {
        let n1 = makeNotification()
        let n2 = makeNotification(isRead: true)
        mockService.stubbedNotifications = [n1, n2]

        await sut.loadNotifications()

        XCTAssertEqual(mockService.fetchCallCount, 1)
        XCTAssertEqual(sut.notifications.count, 2)
    }

    func testLoadNotificationsSetsErrorOnFailure() async {
        mockService.shouldFail = true

        await sut.loadNotifications()

        XCTAssertNotNil(sut.errorMessage)
        XCTAssertTrue(sut.notifications.isEmpty)
    }

    func testMarkAsReadCallsServiceAndUpdatesLocal() async {
        let notifId = UUID()
        let n = makeNotification(id: notifId, isRead: false)
        mockService.stubbedNotifications = [n]
        await sut.loadNotifications()

        await sut.markAsRead(notifId)

        XCTAssertEqual(mockService.markAsReadCallCount, 1)
        XCTAssertEqual(mockService.lastMarkedId, notifId)
        XCTAssertTrue(sut.notifications.first?.isRead == true)
    }

    func testMarkAllAsReadCallsServiceAndUpdatesLocal() async {
        mockService.stubbedNotifications = [
            makeNotification(isRead: false),
            makeNotification(isRead: false)
        ]
        await sut.loadNotifications()

        await sut.markAllAsRead()

        XCTAssertEqual(mockService.markAllAsReadCallCount, 1)
        XCTAssertTrue(sut.notifications.allSatisfy(\.isRead))
    }

    func testUnreadCountReflectsState() async {
        mockService.stubbedNotifications = [
            makeNotification(isRead: false),
            makeNotification(isRead: true),
            makeNotification(isRead: false)
        ]
        await sut.loadNotifications()

        XCTAssertEqual(sut.unreadCount, 2)
    }
}
