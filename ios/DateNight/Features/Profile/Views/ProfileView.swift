import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showEditProfile = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Photo Gallery
                    photoGallery

                    // Content below photo
                    VStack(alignment: .leading, spacing: DNSpace.xl) {
                        statsSection
                        aboutSection
                        interestsSection
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
            .frame(height: UIScreen.main.bounds.height * 0.7)

            // Gradient overlay
            GradientOverlay(opacity: 0.7)

            // Photo indicator bar
            VStack {
                HStack(spacing: 6) {
                    ForEach(0 ..< viewModel.profile.photos.count, id: \.self) { index in
                        Capsule()
                            .fill(index == viewModel.selectedPhotoIndex ? Color.dnPrimary : Color.white.opacity(0.3))
                            .frame(height: 3)
                            .animation(.easeInOut(duration: 0.2), value: viewModel.selectedPhotoIndex)
                    }
                }
                .padding(.horizontal, DNSpace.lg)
                .padding(.top, DNSpace.lg)

                Spacer()

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
                            .shadow(color: .black.opacity(0.3), radius: 8, x: 4, y: 4)
                    }
                }
                .padding(.horizontal, DNSpace.lg)
                .padding(.bottom, DNSpace.lg)
            }
        }
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        HStack(spacing: DNSpace.md) {
            DNStatCard(
                icon: "heart.fill",
                label: "Matches",
                value: "\(viewModel.stats.matches)",
                accentColor: .dnAccentPink
            )

            DNStatCard(
                icon: "calendar",
                label: "Dates",
                value: "\(viewModel.stats.dates)",
                accentColor: .dnPrimary
            )

            DNStatCard(
                icon: "star.fill",
                label: "Events",
                value: "\(viewModel.stats.events)",
                accentColor: .dnSuccess
            )
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: DNSpace.sm) {
            Text("About")
                .dnH3()

            Text(viewModel.profile.bio)
                .dnBody()
        }
    }

    // MARK: - Interests Section

    private var interestsSection: some View {
        VStack(alignment: .leading, spacing: DNSpace.sm) {
            Text("Interests")
                .dnH3()

            FlowLayout(spacing: DNSpace.sm) {
                ForEach(viewModel.profile.interests, id: \.self) { interest in
                    Text(interest)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.dnTextSecondary)
                        .textCase(.uppercase)
                        .padding(.horizontal, DNSpace.lg)
                        .padding(.vertical, DNSpace.sm)
                        .dnNeuRaised(intensity: .light, cornerRadius: DNRadius.full)
                }
            }
        }
    }

    // MARK: - Recent Activity Section

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: DNSpace.sm) {
            Text("Recent Activity")
                .dnH3()

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
                                .dnSmall()
                                .textCase(.uppercase)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Settings Section

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: DNSpace.sm) {
            Text("Settings")
                .dnH3()

            VStack(spacing: DNSpace.sm) {
                ForEach(settingsItems, id: \.self) { item in
                    NavigationLink(destination: EmptyView()) {
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
                    // Log out action
                } label: {
                    DNCard {
                        HStack {
                            Text("Log Out")
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
        ["Edit Profile", "Notifications", "Privacy", "Help"]
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
