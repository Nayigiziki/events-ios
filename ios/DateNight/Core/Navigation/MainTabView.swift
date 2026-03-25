import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0

    private let tabs: [(icon: String, labelKey: String)] = [
        ("safari", "tab_explore"),
        ("sparkles", "tab_discover"),
        ("heart.circle", "tab_dates"),
        ("message", "tab_chats"),
        ("person.circle", "tab_profile")
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Content area
            ZStack {
                Color.dnBackground.ignoresSafeArea()

                switch selectedTab {
                case 0:
                    Text(String(localized: "tab_explore"))
                        .dnH2()
                case 1:
                    Text(String(localized: "tab_discover"))
                        .dnH2()
                case 2:
                    Text(String(localized: "tab_dates"))
                        .dnH2()
                case 3:
                    ChatListView()
                case 4:
                    ProfileView()
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
    }

    private var safeAreaBottomInset: CGFloat {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        return windowScene?.windows.first?.safeAreaInsets.bottom ?? 0
    }
}
