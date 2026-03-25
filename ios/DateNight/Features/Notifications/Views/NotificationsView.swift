import SwiftUI

struct NotificationsView: View {
    @StateObject private var viewModel = NotificationsViewModel()

    var body: some View {
        DNScreen {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("NOTIFICATIONS")
                        .dnH2()

                    Spacer()

                    if notifications.contains(where: { !$0.isRead }) {
                        Button {
                            viewModel.markAllAsRead()
                        } label: {
                            Text("Mark all read")
                                .dnLink()
                        }
                    }
                }
                .padding(DNSpace.lg)

                if viewModel.notifications.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: DNSpace.md) {
                            ForEach(viewModel.notifications) { notification in
                                notificationCard(notification)
                                    .onTapGesture {
                                        viewModel.markAsRead(notification)
                                    }
                            }
                        }
                        .padding(.horizontal, DNSpace.lg)
                        .padding(.bottom, DNSpace.xxl)
                    }
                }
            }
        }
    }

    private var notifications: [MockNotification] {
        viewModel.notifications
    }

    private func notificationCard(_ notification: MockNotification) -> some View {
        DNCard {
            HStack(spacing: DNSpace.md) {
                // Icon circle
                ZStack {
                    Circle()
                        .fill(iconColor(for: notification.type).opacity(0.15))
                        .frame(width: 44, height: 44)

                    Image(systemName: iconName(for: notification.type))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(iconColor(for: notification.type))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(notification.title)
                        .font(.system(size: 16, weight: .bold))
                        .tracking(-0.47)
                        .foregroundColor(.dnTextPrimary)

                    Text(notification.subtitle)
                        .dnCaption()
                        .lineLimit(1)

                    Text(notification.timeAgo)
                        .dnSmall()
                }

                Spacer()

                // Unread dot
                if !notification.isRead {
                    Circle()
                        .fill(Color.dnPrimary)
                        .frame(width: 10, height: 10)
                }
            }
        }
    }

    private func iconName(for type: NotificationType) -> String {
        switch type {
        case .match: "heart.fill"
        case .message: "message.fill"
        case .event: "calendar.fill"
        case .date: "heart.circle.fill"
        case .friend: "person.badge.plus"
        }
    }

    private func iconColor(for type: NotificationType) -> Color {
        switch type {
        case .match: .dnAccentPink
        case .message: .dnPrimary
        case .event: .dnSuccess
        case .date: .dnPrimary
        case .friend: .dnInfo
        }
    }

    private var emptyState: some View {
        VStack(spacing: DNSpace.lg) {
            Spacer()

            Image(systemName: "bell.slash")
                .font(.system(size: 48))
                .foregroundColor(.dnMuted)

            Text("No notifications")
                .dnBody()

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NotificationsView()
}
