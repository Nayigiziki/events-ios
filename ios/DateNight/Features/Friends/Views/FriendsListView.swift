import SwiftUI

struct FriendsListView: View {
    @StateObject private var viewModel = FriendsViewModel()
    @State private var selectedSegment = 0
    @State private var showAddFriends = false

    var body: some View {
        DNScreen {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Friends")
                        .dnH2()
                    Spacer()
                    Button {
                        showAddFriends = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.dnPrimary)
                            .frame(width: 44, height: 44)
                            .dnNeuRaised(intensity: .light, cornerRadius: DNRadius.full)
                    }
                }
                .padding(.horizontal, DNSpace.lg)
                .padding(.top, DNSpace.md)

                // Search bar
                DNTextField(placeholder: "Search friends...", text: $viewModel.searchText, icon: "magnifyingglass")
                    .padding(.horizontal, DNSpace.lg)
                    .padding(.top, DNSpace.md)

                // Segmented control
                segmentedControl
                    .padding(.horizontal, DNSpace.lg)
                    .padding(.top, DNSpace.md)

                // Content
                ScrollView(showsIndicators: false) {
                    if selectedSegment == 0 {
                        friendsTab
                    } else {
                        requestsTab
                    }
                }
                .padding(.top, DNSpace.md)
            }
        }
        .navigationDestination(isPresented: $showAddFriends) {
            AddFriendsView(friendsViewModel: viewModel)
        }
    }

    // MARK: - Segmented Control

    private var segmentedControl: some View {
        HStack(spacing: 0) {
            segmentButton(title: "Friends", index: 0, count: viewModel.friends.count)
            segmentButton(title: "Requests", index: 1, count: viewModel.requests.count)
        }
        .dnNeuPressed(intensity: .light, cornerRadius: DNRadius.md)
    }

    private func segmentButton(title: String, index: Int, count: Int) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedSegment = index
            }
        } label: {
            HStack(spacing: DNSpace.xs) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(selectedSegment == index ? .white : .dnTextSecondary)

                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(selectedSegment == index ? .dnPrimary : .dnTextTertiary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(selectedSegment == index ? Color.white : Color.dnBackground)
                        )
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DNSpace.md)
            .background(
                Group {
                    if selectedSegment == index {
                        RoundedRectangle(cornerRadius: DNRadius.sm, style: .continuous)
                            .fill(Color.dnPrimary)
                    }
                }
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Friends Tab

    private var friendsTab: some View {
        Group {
            if viewModel.filteredFriends.isEmpty {
                emptyState
            } else {
                LazyVStack(spacing: DNSpace.sm) {
                    ForEach(viewModel.filteredFriends) { friend in
                        friendRow(friend)
                    }
                }
                .padding(.horizontal, DNSpace.lg)
                .padding(.bottom, DNSpace.xxl * 3)
            }
        }
    }

    private func friendRow(_ friend: FriendUser) -> some View {
        DNCard {
            HStack(spacing: DNSpace.md) {
                AvatarView(url: URL(string: friend.avatarUrl ?? ""), size: 48)

                VStack(alignment: .leading, spacing: 2) {
                    Text(friend.name)
                        .dnH3()
                    Text(friend.subtitle)
                        .dnCaption()
                }

                Spacer()

                Button {
                    viewModel.removeFriend(friend)
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.dnTextTertiary)
                        .frame(width: 32, height: 32)
                        .dnNeuRaised(intensity: .light, cornerRadius: DNRadius.full)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Requests Tab

    private var requestsTab: some View {
        Group {
            if viewModel.requests.isEmpty {
                emptyState
            } else {
                LazyVStack(spacing: DNSpace.sm) {
                    ForEach(viewModel.requests) { request in
                        requestRow(request)
                    }
                }
                .padding(.horizontal, DNSpace.lg)
                .padding(.bottom, DNSpace.xxl * 3)
            }
        }
    }

    private func requestRow(_ request: FriendRequest) -> some View {
        DNCard {
            HStack(spacing: DNSpace.md) {
                AvatarView(url: URL(string: request.user.avatarUrl ?? ""), size: 48)

                VStack(alignment: .leading, spacing: 2) {
                    Text(request.user.name)
                        .dnH3()
                    Text(request.sentAt)
                        .dnCaption()
                }

                Spacer()

                HStack(spacing: DNSpace.sm) {
                    CompactDNButton(title: "Accept", variant: .primary) {
                        viewModel.acceptRequest(request)
                    }
                    CompactDNButton(title: "Decline", variant: .secondary) {
                        viewModel.declineRequest(request)
                    }
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: DNSpace.md) {
            Spacer()
                .frame(height: 80)
            Image(systemName: "person.2.slash")
                .font(.system(size: 48))
                .foregroundColor(.dnTextTertiary)
            Text("No friends yet")
                .dnH3()
            Text("Add friends to see them here")
                .dnCaption()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Compact DN Button

struct CompactDNButton: View {
    let title: String
    let variant: DNButtonVariant
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button {
            action()
        } label: {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .bold))
                .tracking(0.2)
                .foregroundColor(variant.foregroundColor)
                .padding(.horizontal, DNSpace.md)
                .padding(.vertical, DNSpace.sm)
                .background(
                    RoundedRectangle(cornerRadius: DNRadius.sm, style: .continuous)
                        .fill(variant.backgroundColor)
                )
        }
        .buttonStyle(.plain)
        .dnNeuRaised(intensity: .light, cornerRadius: DNRadius.sm)
    }
}
