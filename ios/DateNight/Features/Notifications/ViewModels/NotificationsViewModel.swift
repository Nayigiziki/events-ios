import Foundation

enum NotificationType: String {
    case match
    case message
    case event
    case date
    case friend
}

struct MockNotification: Identifiable {
    let id: String
    let type: NotificationType
    let title: String
    let subtitle: String
    let timeAgo: String
    var isRead: Bool
}

// MARK: - Mock Data

private let mockNotifications: [MockNotification] = [
    MockNotification(
        id: "n1",
        type: .match,
        title: "New match with Emma!",
        subtitle: "You both liked the Jazz Night event",
        timeAgo: "2m",
        isRead: false
    ),
    MockNotification(
        id: "n2",
        type: .message,
        title: "Sarah sent you a message",
        subtitle: "Hey! Are you free this weekend?",
        timeAgo: "15m",
        isRead: false
    ),
    MockNotification(
        id: "n3",
        type: .event,
        title: "Comedy Show Tomorrow",
        subtitle: "Don't forget your event starts at 8 PM",
        timeAgo: "1h",
        isRead: false
    ),
    MockNotification(
        id: "n4",
        type: .date,
        title: "Date confirmed!",
        subtitle: "Alex accepted your date to the Art Gallery",
        timeAgo: "2h",
        isRead: true
    ),
    MockNotification(
        id: "n5",
        type: .friend,
        title: "Michael wants to be friends",
        subtitle: "Accept or decline the friend request",
        timeAgo: "3h",
        isRead: false
    ),
    MockNotification(
        id: "n6",
        type: .match,
        title: "Jessica matched with you!",
        subtitle: "You have similar interests in Food & Comedy",
        timeAgo: "5h",
        isRead: true
    ),
    MockNotification(
        id: "n7",
        type: .event,
        title: "New event near you",
        subtitle: "Street Food Festival this Saturday",
        timeAgo: "1d",
        isRead: true
    ),
    MockNotification(
        id: "n8",
        type: .message,
        title: "Group chat: Jazz Club Date",
        subtitle: "Alex: Sounds great, count me in!",
        timeAgo: "1d",
        isRead: true
    )
]

@MainActor
final class NotificationsViewModel: ObservableObject {
    @Published var notifications: [MockNotification] = mockNotifications

    func markAsRead(_ notification: MockNotification) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index].isRead = true
        }
    }

    func markAllAsRead() {
        for index in notifications.indices {
            notifications[index].isRead = true
        }
    }
}
