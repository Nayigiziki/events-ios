import SwiftUI

struct UserSwipeView: View {
    @StateObject private var viewModel = DiscoverViewModel()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        DNScreen {
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: DNSpace.xs) {
                        Text("Discover")
                            .dnH2()
                        Text("\(viewModel.users.count - viewModel.currentIndex) people nearby")
                            .dnCaption()
                    }
                    Spacer()
                    Button {
                        withAnimation(.dnModalPresent) {
                            viewModel.showFilters.toggle()
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.dnPrimary)
                            .frame(width: 52, height: 52)
                            .dnNeuRaised(cornerRadius: DNRadius.full)
                    }
                }
                .padding(.horizontal, DNSpace.lg)
                .padding(.vertical, DNSpace.md)

                if viewModel.showFilters {
                    SwipeFiltersView(showFilters: $viewModel.showFilters)
                        .zIndex(10)
                }

                if let currentUser = viewModel.currentUser {
                    // Card deck
                    ZStack {
                        // Next card (behind)
                        if let nextUser = viewModel.nextUser {
                            SwipeCardView(
                                user: nextUser,
                                isTopCard: false
                            )
                            .scaleEffect(0.95)
                            .opacity(0.5)
                        }

                        // Current card (top)
                        SwipeCardView(
                            user: currentUser,
                            isTopCard: true,
                            onSwipeLeft: {
                                viewModel.swipeLeft(userId: currentUser.id)
                            },
                            onSwipeRight: {
                                viewModel.swipeRight(userId: currentUser.id)
                            }
                        )
                        .id(viewModel.currentIndex)
                    }
                    .padding(.horizontal, DNSpace.lg)
                    .padding(.top, DNSpace.sm)

                    Spacer(minLength: DNSpace.md)

                    // Action buttons
                    HStack(spacing: DNSpace.xxl) {
                        // Pass button
                        Button {
                            viewModel.swipeLeft(userId: currentUser.id)
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.dnDestructive)
                                .frame(width: 70, height: 70)
                                .dnNeuRaised(intensity: .heavy, cornerRadius: DNRadius.full)
                        }
                        .buttonStyle(.plain)

                        // Like button
                        Button {
                            viewModel.swipeRight(userId: currentUser.id)
                        } label: {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.dnPrimary)
                                .frame(width: 70, height: 70)
                                .dnNeuRaised(intensity: .heavy, cornerRadius: DNRadius.full)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.bottom, DNSpace.xl)
                } else {
                    // Empty state
                    Spacer()
                    VStack(spacing: DNSpace.md) {
                        Image(systemName: "person.2.slash")
                            .font(.system(size: 48))
                            .foregroundColor(.dnTextTertiary)
                        Text("No more people")
                            .dnH3()
                        Text("Come back later to see new profiles")
                            .dnCaption()
                    }
                    Spacer()
                }
            }
        }
    }
}
