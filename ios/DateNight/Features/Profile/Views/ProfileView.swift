import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel: ProfileViewModel
    @ObservedObject private var languageManager = LanguageManager.shared
    @State private var showEditProfile = false
    @State private var showMatchPreferences = false
    @State private var showSettings = false
    @State private var showNotifications = false
    @State private var showHelpSupport = false
    @State private var showMyReviews = false
    @State private var showFriends = false
    @State private var showOnboarding = false
    @State private var showMyEvents = false

    init(profileService: ProfileServiceProtocol = ProfileService(), userId: UUID = UUID()) {
        _viewModel = StateObject(wrappedValue: ProfileViewModel(profileService: profileService, userId: userId))
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Photo Gallery
                    photoGallery

                    // Content below photo
                    VStack(alignment: .leading, spacing: DNSpace.xl) {
                        interestTagsSection
                        photoThumbnailRow
                        statsSection
                        recentActivitySection
                        settingsSection
                    }
                    .padding(.horizontal, DNSpace.lg)
                    .padding(.top, DNSpace.xl)
                    .padding(.bottom, DNSpace.xxl * 3)
                }
            }
            .background(Color.dnBackground)
            .ignoresSafeArea(edges: .top)
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $showEditProfile) {
                ProfileEditView()
            }
            .navigationDestination(isPresented: $showMatchPreferences) {
                MatchPreferencesView()
            }
            .navigationDestination(isPresented: $showSettings) {
                SettingsView()
            }
            .navigationDestination(isPresented: $showNotifications) {
                NotificationsView()
            }
            .navigationDestination(isPresented: $showHelpSupport) {
                HelpSupportView()
            }
            .navigationDestination(isPresented: $showMyReviews) {
                MyReviewsView()
            }
            .navigationDestination(isPresented: $showFriends) {
                FriendsListView()
            }
            .navigationDestination(isPresented: $showMyEvents) {
                MyEventsView()
            }
            .sheet(isPresented: $showOnboarding) {
                OnboardingView()
            }
            .task {
                await viewModel.loadProfile()
            }
        }
    }

    // MARK: - Photo Gallery

    private var photos: [String] {
        viewModel.profile?.photos ?? []
    }

    private var photoGallery: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $viewModel.selectedPhotoIndex) {
                ForEach(Array(photos.enumerated()), id: \.offset) { index, photo in
                    DNAsyncImage(
                        url: URL(string: photo),
                        height: UIScreen.main.bounds.height * 0.45,
                        cornerRadius: 0
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: UIScreen.main.bounds.height * 0.45)

            // Gradient overlay
            GradientOverlay(opacity: 0.7)

            // Photo indicator bar + overlays
            VStack {
                HStack {
                    Spacer()
                    // Settings gear icon
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.dnTextPrimary)
                            .frame(width: 40, height: 40)
                            .dnNeuRaised(intensity: .light, cornerRadius: DNRadius.full)
                    }
                    .padding(.trailing, DNSpace.lg)
                    .padding(.top, DNSpace.xxl * 2)
                }

                HStack(spacing: 6) {
                    ForEach(0 ..< photos.count, id: \.self) { index in
                        Capsule()
                            .fill(index == viewModel.selectedPhotoIndex ? Color.dnPrimary : Color.white.opacity(0.3))
                            .frame(height: 3)
                            .animation(.easeInOut(duration: 0.2), value: viewModel.selectedPhotoIndex)
                    }
                }
                .padding(.horizontal, DNSpace.lg)
                .padding(.top, DNSpace.sm)

                Spacer()

                // Photo carousel arrow buttons
                HStack {
                    Button {
                        withAnimation {
                            viewModel.selectedPhotoIndex = max(0, viewModel.selectedPhotoIndex - 1)
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.dnTextPrimary)
                            .frame(width: 40, height: 40)
                            .dnNeuRaised(intensity: .light, cornerRadius: DNRadius.full)
                    }
                    Spacer()
                    Button {
                        withAnimation {
                            viewModel.selectedPhotoIndex = min(
                                max(photos.count - 1, 0),
                                viewModel.selectedPhotoIndex + 1
                            )
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.dnTextPrimary)
                            .frame(width: 40, height: 40)
                            .dnNeuRaised(intensity: .light, cornerRadius: DNRadius.full)
                    }
                }
                .padding(.horizontal, DNSpace.lg)

                // Name + age overlay
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: DNSpace.xs) {
                        Text("\(viewModel.profile?.name ?? ""), \(viewModel.profile?.age ?? 0)")
                            .font(.system(size: 30, weight: .heavy))
                            .tracking(-0.6)
                            .foregroundColor(.white)

                        Text(viewModel.profile?.bio ?? "")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white.opacity(0.9))
                    }

                    Spacer()

                    // Edit button
                    Button {
                        showEditProfile = true
                    } label: {
                        Image(systemName: "pencil")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 48, height: 48)
                            .background(
                                Circle()
                                    .fill(Color.dnPrimary)
                            )
                            .dnNeuRaised(intensity: .light, cornerRadius: DNRadius.full)
                    }
                }
                .padding(.horizontal, DNSpace.lg)
                .padding(.bottom, DNSpace.lg)
            }
        }
    }

    // MARK: - Interest Tags Section

    private var interestTagsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DNSpace.sm) {
                ForEach(viewModel.profile?.interests ?? [], id: \.self) { interest in
                    Text(interest.uppercased())
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.dnTextPrimary)
                        .padding(.horizontal, DNSpace.md)
                        .padding(.vertical, DNSpace.sm)
                        .dnNeuRaised(intensity: .light, cornerRadius: DNRadius.sm)
                }
            }
        }
    }

    // MARK: - Photo Thumbnail Row

    private var photoThumbnailRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DNSpace.md) {
                ForEach(Array(photos.enumerated()), id: \.offset) { index, photo in
                    DNAsyncImage(
                        url: URL(string: photo),
                        height: 64,
                        cornerRadius: DNRadius.full
                    )
                    .frame(width: 64)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(index == viewModel.selectedPhotoIndex ? Color.dnPrimary : Color.clear, lineWidth: 3)
                    )
                    .onTapGesture {
                        withAnimation {
                            viewModel.selectedPhotoIndex = index
                        }
                    }
                }
            }
        }
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        HStack(spacing: DNSpace.sm) {
            DNStatCard(
                icon: "heart.fill",
                label: "profile_stat_matches".localized(),
                value: "\(viewModel.stats.matches)",
                accentColor: .dnAccentPink
            )

            DNStatCard(
                icon: "calendar",
                label: "profile_stat_dates".localized(),
                value: "\(viewModel.stats.dates)",
                accentColor: .dnPrimary
            )

            DNStatCard(
                icon: "mappin.and.ellipse",
                label: "profile_stat_events".localized(),
                value: "\(viewModel.stats.events)",
                accentColor: .dnSuccess
            )
        }
    }

    // MARK: - Recent Activity Section

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: DNSpace.sm) {
            Text("profile_recent_activity".localized())
                .dnLabel()
                .textCase(.uppercase)

            LazyVStack(spacing: DNSpace.sm) {
                ForEach(viewModel.activities) { activity in
                    DNCard {
                        HStack(spacing: DNSpace.md) {
                            ZStack {
                                Circle()
                                    .fill(activityColor(for: activity.iconColor))
                                    .frame(width: 44, height: 44)
                                Image(systemName: activity.icon)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(activity.title)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.dnTextPrimary)

                                Text(activity.subtitle)
                                    .dnCaption()
                            }

                            Spacer()

                            Text(activity.timeAgo)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.dnTextTertiary)
                                .padding(.horizontal, DNSpace.sm)
                                .padding(.vertical, DNSpace.xs)
                                .background(
                                    Capsule()
                                        .fill(Color.dnBackground)
                                )
                                .dnNeuRaised(intensity: .light, cornerRadius: DNRadius.full)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Settings Section

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: DNSpace.sm) {
            // Language toggle
            DNCard {
                HStack {
                    Image(systemName: "globe")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.dnPrimary)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Language / Idioma")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.dnTextPrimary)
                        Text(languageManager.displayName)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.dnTextSecondary)
                    }
                    Spacer()
                    Button {
                        withAnimation(.dnButtonPress) {
                            languageManager.toggle()
                        }
                    } label: {
                        Text(languageManager.isSpanish ? "EN" : "ES")
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundColor(.white)
                            .frame(width: 48, height: 32)
                            .background(
                                Capsule()
                                    .fill(Color.dnPrimary)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }

            VStack(spacing: DNSpace.sm) {
                ForEach(settingsItems, id: \.key) { item in
                    Button {
                        handleSettingsTap(item.key)
                    } label: {
                        DNCard {
                            HStack {
                                Text(item.label)
                                    .dnBody()
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.dnTextTertiary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }

                Button {
                    Task { await authViewModel.signOut() }
                } label: {
                    DNCard {
                        HStack {
                            Text("profile_sign_out".localized())
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.dnDestructive)
                            Spacer()
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.dnDestructive)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Helpers

    private struct SettingsItem: Identifiable {
        let key: String
        let label: String
        var id: String { key }
    }

    private var settingsItems: [SettingsItem] {
        var items = [
            SettingsItem(key: "tutorial", label: "profile_settings_tutorial".localized())
        ]

        items.append(contentsOf: [
            SettingsItem(key: "account", label: "profile_settings_account".localized()),
            SettingsItem(key: "preferences", label: "profile_settings_preferences".localized()),
            SettingsItem(key: "notifications", label: "profile_settings_notifications".localized()),
            SettingsItem(key: "privacy", label: "profile_settings_privacy".localized()),
            SettingsItem(key: "help", label: "profile_settings_help".localized()),
            SettingsItem(key: "reviews", label: "profile_settings_reviews".localized()),
            SettingsItem(key: "friends", label: "profile_settings_friends".localized()),
            SettingsItem(key: "events", label: "profile_settings_events".localized())
        ])

        return items
    }

    private func handleSettingsTap(_ key: String) {
        switch key {
        case "tutorial":
            showOnboarding = true
        case "account", "privacy":
            showSettings = true
        case "preferences":
            showMatchPreferences = true
        case "notifications":
            showNotifications = true
        case "help":
            showHelpSupport = true
        case "reviews":
            showMyReviews = true
        case "friends":
            showFriends = true
        case "events":
            showMyEvents = true
        default:
            break
        }
    }

    private func activityColor(for colorName: String) -> Color {
        switch colorName {
        case "pink": .dnAccentPink
        case "purple": .dnPrimary
        case "green": .dnSuccess
        default: .dnPrimary
        }
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: ProposedViewSize(result.sizes[index])
            )
        }
    }

    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> ArrangementResult {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var sizes: [CGSize] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            sizes.append(size)

            if currentX + size.width > maxWidth, currentX > 0 {
                currentX = 0
                currentY += rowHeight + spacing
                rowHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))
            rowHeight = max(rowHeight, size.height)
            currentX += size.width + spacing
        }

        let totalHeight = currentY + rowHeight
        return ArrangementResult(
            positions: positions,
            sizes: sizes,
            size: CGSize(width: maxWidth, height: totalHeight)
        )
    }

    struct ArrangementResult {
        let positions: [CGPoint]
        let sizes: [CGSize]
        let size: CGSize
    }
}
