import SwiftUI

struct MyDatesView: View {
    @StateObject private var viewModel = MyDatesViewModel()

    var body: some View {
        DNScreen {
            NavigationStack {
                ScrollView {
                    VStack(spacing: DNSpace.lg) {
                        header
                        segmentedPicker
                        datesList
                    }
                    .padding(.bottom, DNSpace.xxl * 3)
                }
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: DNSpace.xs) {
            Text("MY DATES")
                .font(.system(size: 28, weight: .black))
                .tracking(-0.6)
                .foregroundColor(.dnTextPrimary)
                .textCase(.uppercase)

            Text("Manage your upcoming and past dates")
                .dnCaption()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, DNSpace.lg)
        .padding(.top, DNSpace.md)
    }

    // MARK: - Segmented Picker

    private var segmentedPicker: some View {
        HStack(spacing: 0) {
            tabButton(title: "Upcoming", index: 0)
            tabButton(title: "Past", index: 1)
            tabButton(title: "Cancelled", index: 2)
        }
        .padding(4)
        .dnNeuRaised(cornerRadius: DNRadius.xl)
        .padding(.horizontal, DNSpace.lg)
    }

    private func tabButton(title: String, index: Int) -> some View {
        Button {
            withAnimation(.dnTabSwitch) {
                viewModel.selectedTab = index
            }
        } label: {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .bold))
                .textCase(.uppercase)
                .foregroundColor(
                    viewModel.selectedTab == index
                        ? .white
                        : .dnTextSecondary
                )
                .frame(maxWidth: .infinity)
                .frame(minHeight: 40)
                .background(
                    Group {
                        if viewModel.selectedTab == index {
                            Capsule()
                                .fill(Color.dnPrimary)
                        }
                    }
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Dates List

    @ViewBuilder
    private var datesList: some View {
        let dates: [DateRequest] = switch viewModel.selectedTab {
        case 0: viewModel.upcoming
        case 1: viewModel.past
        case 2: viewModel.cancelled
        default: []
        }

        if dates.isEmpty {
            emptyState
        } else {
            LazyVStack(spacing: DNSpace.lg) {
                ForEach(dates) { dateReq in
                    NavigationLink(destination: DateDetailView(dateRequest: dateReq)) {
                        myDateCard(dateReq)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, DNSpace.lg)
                }
            }
        }
    }

    // MARK: - Date Card

    private func myDateCard(_ dateRequest: DateRequest) -> some View {
        DNCard {
            HStack(spacing: DNSpace.md) {
                dateCardImage(dateRequest)
                dateCardInfo(dateRequest)
                Spacer()
                dateCardTrailing(dateRequest)
            }
        }
    }

    private func dateCardImage(_ dateRequest: DateRequest) -> some View {
        DNAsyncImage(
            url: URL(string: dateRequest.event?.imageUrl ?? ""),
            height: 80,
            cornerRadius: DNRadius.sm
        )
        .frame(width: 80)
    }

    private func dateCardInfo(_ dateRequest: DateRequest) -> some View {
        VStack(alignment: .leading, spacing: DNSpace.xs) {
            Text(dateRequest.event?.title ?? "Untitled")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.dnTextPrimary)
                .lineLimit(1)

            HStack(spacing: DNSpace.xs) {
                Image(systemName: "calendar")
                    .font(.system(size: 11, weight: .bold))
                Text(dateRequest.event?.date ?? "")
                    .font(.system(size: 12, weight: .bold))
            }
            .foregroundColor(.dnTextSecondary)

            dateCardAvatars(dateRequest)
        }
    }

    private func dateCardAvatars(_ dateRequest: DateRequest) -> some View {
        HStack(spacing: -6) {
            ForEach(Array((dateRequest.attendees ?? []).prefix(4))) { attendee in
                AvatarView(url: URL(string: attendee.avatarUrl ?? ""), size: 24)
            }
            if (dateRequest.attendees?.count ?? 0) > 4 {
                Text("+\((dateRequest.attendees?.count ?? 0) - 4)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.dnTextSecondary)
                    .frame(width: 24, height: 24)
                    .background(Circle().fill(Color.dnBackground))
                    .dnNeuRaised(intensity: .light, cornerRadius: DNRadius.full)
            }
        }
    }

    private func dateCardTrailing(_ dateRequest: DateRequest) -> some View {
        VStack(alignment: .trailing, spacing: DNSpace.sm) {
            StatusBadge(status: dateRequest.status.rawValue)
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.dnTextTertiary)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: DNSpace.md) {
            let (icon, message) = emptyStateContent

            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.dnTextTertiary)
                .frame(width: 80, height: 80)
                .dnNeuRaised(cornerRadius: DNRadius.full)

            Text(message)
                .dnH3()

            Text("Explore events and create a date to get started")
                .dnCaption()
                .multilineTextAlignment(.center)
        }
        .padding(.top, 60)
        .padding(.horizontal, DNSpace.xxl)
    }

    private var emptyStateContent: (String, String) {
        switch viewModel.selectedTab {
        case 0: ("calendar.badge.plus", "No upcoming dates")
        case 1: ("clock.arrow.circlepath", "No past dates")
        case 2: ("calendar.badge.minus", "No cancelled dates")
        default: ("calendar", "No dates")
        }
    }
}
