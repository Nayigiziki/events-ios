import SwiftUI

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()

    var body: some View {
        NavigationStack {
            DNScreen {
                ScrollView {
                    VStack(spacing: DNSpace.xl) {
                        headerView
                        filterChips
                        eventList
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
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            Text("Explore Events")
                .dnH2()
            Spacer()
            Button {} label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.dnPrimary)
                    .frame(width: 48, height: 48)
                    .dnNeuRaised(cornerRadius: DNRadius.sm)
            }
            .buttonStyle(.plain)
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
        }
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
                .opacity(0)
                .onAppear {}
                .modifier(StaggeredEntryModifier(index: index))
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
            content.dnNeuRaised(cornerRadius: DNRadius.full)
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
