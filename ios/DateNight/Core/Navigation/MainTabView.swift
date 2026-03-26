import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0
    @State private var showFeedback = false

    private let tabs: [(icon: String, labelKey: String)] = [
        ("house.fill", "tab_explore"),
        ("bolt.fill", "tab_discover"),
        ("heart.fill", "tab_dates"),
        ("bubble.left.and.bubble.right.fill", "tab_chats"),
        ("person.fill", "tab_profile")
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Content area
            ZStack {
                Color.dnBackground.ignoresSafeArea()

                switch selectedTab {
                case 0:
                    NavigationStack {
                        FeedView()
                    }
                case 1:
                    NavigationStack {
                        UserSwipeView()
                    }
                case 2:
                    NavigationStack {
                        MatchesView()
                    }
                case 3:
                    NavigationStack {
                        ChatListView()
                    }
                case 4:
                    NavigationStack {
                        ProfileView()
                    }
                default:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom bottom tab bar
            VStack(spacing: 0) {
                HStack {
                    ForEach(0 ..< tabs.count, id: \.self) { index in
                        Spacer()
                        DNTabButton(
                            icon: tabs[index].icon,
                            label: String(localized: String.LocalizationValue(tabs[index].labelKey)),
                            isActive: selectedTab == index
                        ) {
                            selectedTab = index
                        }
                        Spacer()
                    }
                }
                .padding(.top, DNSpace.sm)
                .padding(.bottom, DNSpace.xs)
            }
            .padding(.bottom, safeAreaBottomInset)
            .dnNeuRaised(intensity: .medium, cornerRadius: 0)
        }
        .ignoresSafeArea(edges: .bottom)
        .overlay(alignment: .bottomTrailing) {
            // Floating feedback button
            Button {
                showFeedback = true
            } label: {
                Image(systemName: "bubble.left.and.text.bubble.right.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(
                        Circle()
                            .fill(Color.dnPrimary)
                            .shadow(color: Color.dnPrimary.opacity(0.4), radius: 8, x: 0, y: 4)
                    )
            }
            .buttonStyle(.plain)
            .padding(.trailing, DNSpace.lg)
            .padding(.bottom, 100)
        }
        .sheet(isPresented: $showFeedback) {
            FeedbackChatView()
        }
    }

    private var safeAreaBottomInset: CGFloat {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        return windowScene?.windows.first?.safeAreaInsets.bottom ?? 0
    }
}
