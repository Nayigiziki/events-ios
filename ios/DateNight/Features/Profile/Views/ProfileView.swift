import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showEditProfile = false
    @State private var showMatchPreferences = false
    @State private var showSettings = false
    @State private var showNotifications = false
    @State private var showHelpSupport = false
    @State private var showMyReviews = false
    @State private var showFriends = false
    @State private var showOnboarding = false
    @State private var showMyEvents = false

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
        }
    }

    // MARK: - Photo Gallery

    private var photoGallery: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $viewModel.selectedPhotoIndex) {
                ForEach(Array(viewModel.profile.photos.enumerated()), id: \.offset) { index, photo in
                    AsyncImage(url: URL(string: photo)) { phase in
                        switch phase {
                        case let .success(image):
                            image
                                .resizable()
                                .scaledToFill()
                        default:
                            Color.dnBackground
                        }
                    }
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
                        // Settings action
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
                    ForEach(0 ..< viewModel.profile.photos.count, id: \.self) { index in
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
                                viewModel.profile.photos.count - 1,
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
                        Text("\(viewModel.profile.name), \(viewModel.profile.age)")
                            .font(.system(size: 30, weight: .heavy))
                            .tracking(-0.6)
                            .foregroundColor(.white)

                        Text(viewModel.profile.bio)
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
                ForEach(viewModel.profile.interests, id: \.self) { interest in
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
                ForEach(Array(viewModel.profile.photos.enumerated()), id: \.offset) { index, photo in
                    AsyncImage(url: URL(string: photo)) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color.dnMuted
                    }
                    .frame(width: 64, height: 64)
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
                label: "Matches",
                value: "\(viewModel.stats.matches)",
                accentColor: .dnAccentPink
            )

            DNStatCard(
                icon: "calendar",
                label: "Citas",
                value: "\(viewModel.stats.dates)",
                accentColor: .dnPrimary
            )

            DNStatCard(
                icon: "mappin.and.ellipse",
                label: "Eventos",
                value: "\(viewModel.stats.events)",
                accentColor: .dnSuccess
            )
        }
    }

    // MARK: - Recent Activity Section

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: DNSpace.sm) {
            Text("ACTIVIDAD RECIENTE")
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
            VStack(spacing: DNSpace.sm) {
                ForEach(settingsItems, id: \.self) { item in
                    Button {
                        handleSettingsTap(item)
                    } label: {
                        DNCard {
                            HStack {
                                Text(item)
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
                    authViewModel.signOut()
                } label: {
                    DNCard {
                        HStack {
                            Text("Cerrar Sesión")
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

    private var settingsItems: [String] {
        [
            "Ver Tutorial de Inicio",
            "Explorador de Diseños",
            "Galería de Pantallas",
            "Configuración de Cuenta",
            "Preferencias",
            "Notificaciones",
            "Privacidad y Seguridad",
            "Ayuda y Soporte",
            "Mis Reseñas",
            "Mis Amigos",
            "Mis Eventos"
        ]
    }

    private func handleSettingsTap(_ item: String) {
        switch item {
        case "Ver Tutorial de Inicio":
            showOnboarding = true
        case "Configuración de Cuenta", "Privacidad y Seguridad":
            showSettings = true
        case "Preferencias":
            showMatchPreferences = true
        case "Notificaciones":
            showNotifications = true
        case "Ayuda y Soporte":
            showHelpSupport = true
        case "Mis Reseñas":
            showMyReviews = true
        case "Mis Amigos":
            showFriends = true
        case "Mis Eventos":
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
