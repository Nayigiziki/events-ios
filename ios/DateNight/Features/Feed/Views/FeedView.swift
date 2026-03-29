import SwiftUI

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()

    var body: some View {
        DNScreen {
            ScrollView {
                VStack(spacing: DNSpace.xl) {
                    searchBar
                    filterChips

                    if viewModel.isLoading, viewModel.events.isEmpty {
                        Spacer().frame(height: 60)
                        ProgressView()
                            .tint(.dnPrimary)
                    } else if viewModel.isEmpty {
                        emptyState
                    } else {
                        eventList
                    }
                }
                .padding(.bottom, DNSpace.xxl)
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(for: Event.self) { event in
            EventDetailView(event: event)
        }
        .task {
            await viewModel.loadEvents()
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: DNSpace.sm) {
            DNTextField(
                placeholder: "Search events...",
                text: $viewModel.searchText,
                icon: "magnifyingglass"
            )
            .submitLabel(.search)
            .onSubmit {
                Task { await viewModel.searchEvents() }
            }
        }
        .padding(.horizontal, DNSpace.lg)
        .padding(.top, DNSpace.lg)
    }

    // MARK: - Filter Chips

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DNSpace.md) {
                ForEach(viewModel.categories, id: \.self) { category in
                    let isActive = viewModel.selectedCategory == category
                    Button {
                        withAnimation(.dnButtonPress) {
                            viewModel.selectedCategory = category
                        }
                    } label: {
                        Text(category)
                            .font(.system(size: 14, weight: .bold))
                            .tracking(0.2)
                            .foregroundColor(isActive ? .white : .dnTextPrimary)
                            .padding(.horizontal, DNSpace.xl)
                            .padding(.vertical, DNSpace.md)
                    }
                    .buttonStyle(.plain)
                    .background(
                        Group {
                            if isActive {
                                Capsule()
                                    .fill(Color.dnPrimary)
                            }
                        }
                    )
                    .modifier(CategoryChipModifier(isActive: isActive))
                }
            }
            .padding(.horizontal, DNSpace.lg)
            .padding(.top, DNSpace.lg)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: DNSpace.md) {
            Spacer().frame(height: 60)
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 48))
                .foregroundColor(.dnTextTertiary)
            Text("No events found")
                .dnH3()
            Text("Try a different search or category")
                .dnBody()
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Event List

    private var eventList: some View {
        LazyVStack(spacing: DNSpace.xl) {
            ForEach(Array(viewModel.filteredEvents.enumerated()), id: \.element.id) { index, event in
                EventCardView(
                    event: event,
                    isLiked: viewModel.likedEvents.contains(event.id.uuidString),
                    onToggleLike: {
                        viewModel.toggleLike(eventId: event.id.uuidString)
                    }
                )
                .modifier(StaggeredEntryModifier(index: index))
                .onAppear {
                    if event.id == viewModel.filteredEvents.last?.id {
                        Task { await viewModel.loadMore() }
                    }
                }
            }

            if viewModel.isLoading, !viewModel.events.isEmpty {
                ProgressView()
                    .tint(.dnPrimary)
                    .padding(.vertical, DNSpace.lg)
            }
        }
        .padding(.horizontal, DNSpace.lg)
    }
}

// MARK: - Category Chip Modifier

private struct CategoryChipModifier: ViewModifier {
    let isActive: Bool

    func body(content: Content) -> some View {
        if isActive {
            content.dnNeuPressed(cornerRadius: DNRadius.full)
        } else {
            content.dnNeuRaised(intensity: .heavy, cornerRadius: DNRadius.full)
        }
    }
}

// MARK: - Staggered Entry Modifier

private struct StaggeredEntryModifier: ViewModifier {
    let index: Int
    @State private var appeared = false

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .onAppear {
                withAnimation(.dnCardEntry.delay(Double(index) * 0.05)) {
                    appeared = true
                }
            }
    }
}
