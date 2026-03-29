import SwiftUI

struct AddFriendsView: View {
    @ObservedObject var friendsViewModel: FriendsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        DNScreen {
            VStack(spacing: 0) {
                // Search bar
                DNTextField(
                    placeholder: "Search by name...",
                    text: $friendsViewModel.addFriendSearchText,
                    icon: "magnifyingglass"
                )
                .padding(.horizontal, DNSpace.lg)
                .padding(.top, DNSpace.md)
                .onChange(of: friendsViewModel.addFriendSearchText) { _ in
                    Task { await friendsViewModel.searchUsers() }
                }

                // Results
                ScrollView(showsIndicators: false) {
                    if friendsViewModel.searchResults.isEmpty, !friendsViewModel.addFriendSearchText.isEmpty {
                        VStack(spacing: DNSpace.md) {
                            Spacer()
                                .frame(height: 80)
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 48))
                                .foregroundColor(.dnTextTertiary)
                            Text("No users found")
                                .dnH3()
                            Text("Try a different name")
                                .dnCaption()
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        LazyVStack(spacing: DNSpace.sm) {
                            ForEach(friendsViewModel.searchResults) { user in
                                userRow(user)
                            }
                        }
                        .padding(.horizontal, DNSpace.lg)
                        .padding(.top, DNSpace.md)
                        .padding(.bottom, DNSpace.xxl * 3)
                    }
                }
            }
        }
        .navigationTitle("Add Friends")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            friendsViewModel.addFriendSearchText = ""
            friendsViewModel.searchResults = []
        }
    }

    private func userRow(_ user: UserProfile) -> some View {
        DNCard {
            HStack(spacing: DNSpace.md) {
                AvatarView(url: URL(string: user.avatarUrl ?? ""), size: 48)

                VStack(alignment: .leading, spacing: 2) {
                    Text(user.name)
                        .dnH3()
                    if let bio = user.bio {
                        Text(bio)
                            .dnCaption()
                    }
                }

                Spacer()

                if friendsViewModel.friendIds.contains(user.id) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.dnSuccess)
                } else {
                    CompactDNButton(title: "Add", variant: .primary) {
                        Task { await friendsViewModel.sendFriendRequest(to: user) }
                    }
                }
            }
        }
    }
}
