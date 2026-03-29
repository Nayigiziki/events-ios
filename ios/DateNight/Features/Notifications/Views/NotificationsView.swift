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

                    if viewModel.unreadCount > 0 {
                        Button {
                            Task { await viewModel.markAllAsRead() }
                        } label: {
                            Text("Mark all read")
                                .dnLink()
                        }
                    }
                }
                .padding(DNSpace.lg)

                if viewModel.notifications.isEmpty, !viewModel.isLoading {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: DNSpace.md) {
                            ForEach(viewModel.notifications) { notification in
                                notificationCard(notification)
                                    .onTapGesture {
                                        Task { await viewModel.markAsRead(notification.id) }
                                    }
                            }
                        }
                        .padding(.horizontal, DNSpace.lg)
                        .padding(.bottom, DNSpace.xxl)
                    }
                }
            }
        }
        .task {
            await viewModel.loadNotifications()
        }
    }

    private func notificationCard(_ notification: AppNotification) -> some View {
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

                    if let date = notification.createdAt {
                        Text(date, style: .relative)
                            .dnSmall()
                    }
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

    private func iconName(for type: String) -> String {
        switch type {
        case "match": "heart.fill"
        case "message": "message.fill"
        case "event": "calendar.fill"
        case "date": "heart.circle.fill"
        case "friend": "person.badge.plus"
        default: "bell.fill"
        }
    }

    private func iconColor(for type: String) -> Color {
        switch type {
        case "match": .dnAccentPink
        case "message": .dnPrimary
        case "event": .dnSuccess
        case "date": .dnPrimary
        case "friend": .dnInfo
        default: .dnTextSecondary
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
