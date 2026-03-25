import SwiftUI

struct MyEventsView: View {
    @StateObject private var viewModel = MyEventsViewModel()
    @State private var showAddEvent = false

    var body: some View {
        NavigationStack {
            DNScreen {
                VStack(spacing: 0) {
                    header
                    tabPicker
                    eventsList
                }
            }
        }
        .sheet(isPresented: $showAddEvent) {
            AddEventView()
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("My Events")
                .dnH2()
            Spacer()
            Button { showAddEvent = true } label: {
                Image(systemName: "plus.circle")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.dnPrimary)
                    .frame(width: 52, height: 52)
                    .dnNeuRaised(cornerRadius: DNRadius.full)
            }
        }
        .padding(.horizontal, DNSpace.lg)
        .padding(.vertical, DNSpace.md)
    }

    // MARK: - Tab Picker

    private var tabPicker: some View {
        HStack(spacing: DNSpace.sm) {
            ForEach(MyEventsViewModel.Tab.allCases, id: \.self) { tab in
                FilterChip(
                    title: tab.rawValue,
                    isActive: Binding(
                        get: { viewModel.selectedTab == tab },
                        set: { active in
                            if active { viewModel.selectedTab = tab }
                        }
                    )
                )
            }
            Spacer()
        }
        .padding(.horizontal, DNSpace.lg)
        .padding(.bottom, DNSpace.md)
    }

    // MARK: - Events List

    private var eventsList: some View {
        ScrollView {
            LazyVStack(spacing: DNSpace.lg) {
                let events = viewModel.selectedTab == .created
                    ? viewModel.createdEvents
                    : viewModel.attendingEvents

                if events.isEmpty {
                    emptyState
                } else {
                    ForEach(events) { event in
                        if viewModel.selectedTab == .created {
                            createdEventRow(event)
                        } else {
                            attendingEventRow(event)
                        }
                    }
                }
            }
            .padding(.horizontal, DNSpace.lg)
            .padding(.vertical, DNSpace.md)
        }
    }

    // MARK: - Created Event Row

    private func createdEventRow(_ event: Event) -> some View {
        DNCard {
            HStack(spacing: DNSpace.md) {
                eventThumbnail(event)
                eventInfo(event)
                Spacer()
                eventActions(event)
            }
        }
    }

    private func eventThumbnail(_ event: Event) -> some View {
        DNAsyncImage(
            url: URL(string: event.imageUrl ?? ""),
            height: 80,
            cornerRadius: DNRadius.sm
        )
        .frame(width: 80)
    }

    private func eventInfo(_ event: Event) -> some View {
        VStack(alignment: .leading, spacing: DNSpace.xs) {
            Text(event.title)
                .dnLabel()
                .lineLimit(1)
            Text(event.date)
                .dnSmall()
            HStack(spacing: DNSpace.xs) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.dnPrimary)
                Text("\(event.attendees?.count ?? 0) attending")
                    .dnSmall()
            }
        }
    }

    private func eventActions(_ event: Event) -> some View {
        VStack(spacing: DNSpace.md) {
            Button { viewModel.editEvent(event) } label: {
                Image(systemName: "pencil")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.dnPrimary)
                    .frame(width: 36, height: 36)
                    .dnNeuRaised(intensity: .light, cornerRadius: DNRadius.full)
            }
            .buttonStyle(.plain)

            Button { viewModel.deleteEvent(event) } label: {
                Image(systemName: "trash")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.dnDestructive)
                    .frame(width: 36, height: 36)
                    .dnNeuRaised(intensity: .light, cornerRadius: DNRadius.full)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Attending Event Row

    private func attendingEventRow(_ event: Event) -> some View {
        DNCard {
            HStack(spacing: DNSpace.md) {
                DNAsyncImage(
                    url: URL(string: event.imageUrl ?? ""),
                    height: 80,
                    cornerRadius: DNRadius.sm
                )
                .frame(width: 80)

                VStack(alignment: .leading, spacing: DNSpace.xs) {
                    Text(event.title)
                        .dnLabel()
                        .lineLimit(1)

                    Text("\(event.date) \u{2022} \(event.time)")
                        .dnSmall()

                    Text(event.venue)
                        .dnCaption()
                        .lineLimit(1)
                }

                Spacer()

                StatusBadge(status: event.category)
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: DNSpace.md) {
            Spacer().frame(height: 60)
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 48))
                .foregroundColor(.dnTextTertiary)
            Text("Create your first event")
                .dnH3()
            Text("Tap the + button to get started")
                .dnBody()
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
