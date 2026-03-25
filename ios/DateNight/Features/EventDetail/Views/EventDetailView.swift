import SwiftUI

struct EventDetailView: View {
    @StateObject private var viewModel: EventDetailViewModel
    @Environment(\.dismiss) private var dismiss

    init(event: Event) {
        _viewModel = StateObject(wrappedValue: EventDetailViewModel(event: event))
    }

    var body: some View {
        if let event = viewModel.event {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 0) {
                        heroSection(event: event)
                        detailContent(event: event)
                    }
                    .padding(.bottom, 100)
                }
                .ignoresSafeArea(edges: .top)

                stickyBottomBar(event: event)
            }
            .background(Color.dnBackground)
            .navigationBarHidden(true)
            .sheet(isPresented: $viewModel.showCreateDate) {
                CreateDateSheet(viewModel: viewModel)
            }
        }
    }

    // MARK: - Hero Section

    private func heroSection(event: Event) -> some View {
        ZStack(alignment: .topLeading) {
            heroImage(event: event)
            heroOverlayContent(event: event)
        }
    }

    private func heroImage(event: Event) -> some View {
        GeometryReader { geo in
            AsyncImage(url: URL(string: event.imageUrl ?? "")) { phase in
                switch phase {
                case let .success(image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    heroPlaceholder
                case .empty:
                    heroPlaceholder
                @unknown default:
                    heroPlaceholder
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
        }
        .frame(height: UIScreen.main.bounds.height * 0.6)
        .overlay(
            LinearGradient(
                colors: [
                    .black.opacity(0.4),
                    .clear,
                    .clear,
                    .black.opacity(0.7)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private func heroOverlayContent(event: Event) -> some View {
        VStack {
            heroNavigationBar
            Spacer()
            heroEventInfo(event: event)
        }
    }

    private var heroNavigationBar: some View {
        HStack {
            Button { dismiss() } label: {
                heroCircleButton(icon: "chevron.left")
            }
            Spacer()
            Button {} label: {
                heroCircleButton(icon: "square.and.arrow.up")
            }
        }
        .padding(.horizontal, DNSpace.lg)
        .padding(.top, 56)
    }

    private func heroCircleButton(icon: String) -> some View {
        Image(systemName: icon)
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.dnTextPrimary)
            .frame(width: 48, height: 48)
            .background(Circle().fill(Color.dnBackground))
            .dnNeuRaised(intensity: .light, cornerRadius: DNRadius.full)
    }

    private func heroEventInfo(event: Event) -> some View {
        VStack(alignment: .leading, spacing: DNSpace.md) {
            HStack(spacing: DNSpace.sm) {
                Text(event.category.uppercased())
                    .font(.system(size: 11, weight: .heavy))
                    .tracking(0.8)
                    .foregroundColor(.white)
                    .padding(.horizontal, DNSpace.lg)
                    .padding(.vertical, DNSpace.sm)
                    .background(
                        Capsule()
                            .fill(Color.dnPrimary)
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 2, y: 2)
                    )
                Text(event.venue)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }

            Text(event.title)
                .font(.system(size: 30, weight: .heavy))
                .tracking(-0.5)
                .foregroundColor(.white)
                .lineLimit(3)

            VStack(alignment: .leading, spacing: DNSpace.sm) {
                HStack(spacing: DNSpace.sm) {
                    Image(systemName: "calendar")
                        .font(.system(size: 15, weight: .bold))
                    Text(event.date)
                        .font(.system(size: 15, weight: .bold))
                    Text("\u{2022}")
                    Image(systemName: "clock")
                        .font(.system(size: 15, weight: .bold))
                    Text(event.time)
                        .font(.system(size: 15, weight: .bold))
                }
                HStack(spacing: DNSpace.sm) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 15, weight: .bold))
                    Text(event.location)
                        .font(.system(size: 15, weight: .bold))
                }
            }
            .foregroundColor(.white)
        }
        .padding(.horizontal, DNSpace.xl)
        .padding(.bottom, DNSpace.xl)
    }

    private var heroPlaceholder: some View {
        Rectangle()
            .fill(Color.dnMuted.opacity(0.3))
            .overlay(
                Image(systemName: "photo")
                    .font(.system(size: 50))
                    .foregroundColor(.dnTextTertiary)
            )
    }

    // MARK: - Detail Content

    private func detailContent(event: Event) -> some View {
        VStack(alignment: .leading, spacing: DNSpace.xl) {
            // Quick Info Grid
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: DNSpace.lg),
                GridItem(.flexible(), spacing: DNSpace.lg)
            ], spacing: DNSpace.lg) {
                DNStatCard(
                    icon: "calendar",
                    label: "DATE",
                    value: event.date,
                    accentColor: .dnAccentPink
                )
                DNStatCard(
                    icon: "clock",
                    label: "TIME",
                    value: event.time,
                    accentColor: .dnPrimary
                )
                DNStatCard(
                    icon: "building.2",
                    label: "VENUE",
                    value: event.venue,
                    accentColor: .dnInfo
                )
                DNStatCard(
                    icon: "dollarsign.circle",
                    label: "PRICE",
                    value: event.price,
                    accentColor: .dnSuccess
                )
            }

            // Description
            VStack(alignment: .leading, spacing: DNSpace.md) {
                Text("About")
                    .dnH3()
                Text(event.description)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.dnTextSecondary)
                    .lineSpacing(4)
            }

            // Attendees
            attendeesSection(event: event)
        }
        .padding(DNSpace.xl)
    }

    // MARK: - Attendees

    private func attendeesSection(event: Event) -> some View {
        VStack(alignment: .leading, spacing: DNSpace.md) {
            HStack {
                Text("Who's Going")
                    .dnH3()
                Spacer()
                HStack(spacing: DNSpace.xs) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 14, weight: .bold))
                    Text("\(event.attendees?.count ?? 0) interested")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(.dnPrimary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DNSpace.md) {
                    ForEach(event.attendees ?? []) { user in
                        VStack(spacing: DNSpace.sm) {
                            AvatarView(
                                url: URL(string: user.avatarUrl ?? ""),
                                size: 64
                            )
                            Text(user.name)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.dnTextPrimary)
                                .frame(width: 64)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Sticky Bottom Bar

    private func stickyBottomBar(event: Event) -> some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: DNSpace.xs) {
                    Text("Price")
                        .dnCaption()
                    Text(event.price)
                        .font(.system(size: 22, weight: .heavy))
                        .foregroundColor(.dnTextPrimary)
                }
                Spacer()
                DNButton("Create Date", variant: .primary) {
                    viewModel.showCreateDate = true
                }
                .frame(maxWidth: 200)
            }
            .padding(.horizontal, DNSpace.xl)
            .padding(.vertical, DNSpace.lg)
            .background(Color.dnBackground)
            .dnNeuRaised(intensity: .medium, cornerRadius: 0)
        }
    }
}
