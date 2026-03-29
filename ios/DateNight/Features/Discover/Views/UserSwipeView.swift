import SwiftUI

struct UserSwipeView: View {
    @StateObject private var viewModel = DiscoverViewModel()
    @EnvironmentObject private var authService: AuthService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var selectedProfileUser: UserProfile?

    var body: some View {
        DNScreen {
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: DNSpace.xs) {
                        Text("discover_title".localized())
                            .dnH2()
                        Text(String(format: "discover_people_nearby".localized(), viewModel.remainingCount))
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
                    SwipeFiltersView(
                        showFilters: $viewModel.showFilters,
                        filters: $viewModel.filters,
                        onApply: {
                            Task { await viewModel.loadUsers() }
                        }
                    )
                    .zIndex(10)
                }

                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.5)
                    Spacer()
                } else if let currentUser = viewModel.currentUser {
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
                                Task { await viewModel.swipeLeft(userId: currentUser.id) }
                            },
                            onSwipeRight: {
                                Task { await viewModel.swipeRight(userId: currentUser.id) }
                            },
                            onInfoTapped: {
                                selectedProfileUser = currentUser
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
                            Task { await viewModel.swipeLeft(userId: currentUser.id) }
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.dnDestructive)
                                .frame(width: 64, height: 64)
                                .dnNeuRaised(intensity: .heavy, cornerRadius: DNRadius.full)
                        }
                        .buttonStyle(.plain)

                        // Like button — larger and purple
                        Button {
                            Task { await viewModel.swipeRight(userId: currentUser.id) }
                        } label: {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 80, height: 80)
                                .background(
                                    Circle()
                                        .fill(Color.dnPrimary)
                                )
                                .dnNeuCTAButton(cornerRadius: DNRadius.full)
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
                        Text("discover_no_more_people".localized())
                            .dnH3()
                        Text("discover_come_back_later".localized())
                            .dnCaption()
                    }
                    Spacer()
                }
            }
        }
        .fullScreenCover(isPresented: $viewModel.showMatchDetail) {
            if let matched = viewModel.matchedUser {
                MatchDetailView(
                    viewModel: MatchDetailViewModel(
                        matchedUser: matched,
                        currentUserInterests: authService.currentUser?.interests ?? []
                    ),
                    currentUser: authService.currentUser,
                    onSendMessage: {
                        viewModel.dismissMatch()
                    },
                    onKeepSwiping: {
                        viewModel.dismissMatch()
                    }
                )
            }
        }
        .fullScreenCover(item: $selectedProfileUser) { user in
            UserProfileModal(
                user: user,
                onLike: {
                    Task { await viewModel.swipeRight(userId: user.id) }
                },
                onPass: {
                    Task { await viewModel.swipeLeft(userId: user.id) }
                }
            )
        }
        .task {
            await viewModel.loadUsers()
        }
    }
}
