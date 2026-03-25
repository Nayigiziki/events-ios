import SwiftUI

struct DateDetailView: View {
    @StateObject private var viewModel: DateDetailViewModel
    @Environment(\.dismiss) private var dismiss

    init(dateRequest: DateRequest) {
        _viewModel = StateObject(wrappedValue: DateDetailViewModel(dateRequest: dateRequest))
    }

    var body: some View {
        DNScreen {
            NavigationStack {
                ZStack(alignment: .bottom) {
                    ScrollView {
                        VStack(spacing: 0) {
                            heroSection
                            contentSection
                        }
                        .padding(.bottom, 120)
                    }
                    .ignoresSafeArea(edges: .top)

                    actionButtons
                }
                .navigationBarHidden(true)
                .sheet(isPresented: $viewModel.showChat) {
                    if let event = viewModel.dateRequest.event {
                        GroupChatView(groupName: event.title)
                    }
                }
            }
        }
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        ZStack(alignment: .topLeading) {
            heroImage
            heroOverlay
        }
    }

    private var heroImage: some View {
        GeometryReader { geo in
            AsyncImage(url: URL(string: viewModel.dateRequest.event?.imageUrl ?? "")) { phase in
                switch phase {
                case let .success(image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    imagePlaceholder
                case .empty:
                    imagePlaceholder
                @unknown default:
                    imagePlaceholder
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
        }
        .frame(height: 200)
        .overlay(GradientOverlay(opacity: 0.7))
    }

    private var heroOverlay: some View {
        VStack {
            // Navigation bar
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.dnTextPrimary)
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(Color.dnBackground))
                        .dnNeuRaised(intensity: .light, cornerRadius: DNRadius.full)
                }
                Spacer()
            }
            .padding(.horizontal, DNSpace.lg)
            .padding(.top, 56)

            Spacer()

            // Title + date overlaid
            VStack(alignment: .leading, spacing: DNSpace.xs) {
                if let event = viewModel.dateRequest.event {
                    Text(event.title)
                        .font(.system(size: 24, weight: .heavy))
                        .foregroundColor(.white)

                    HStack(spacing: DNSpace.sm) {
                        Image(systemName: "calendar")
                            .font(.system(size: 13, weight: .bold))
                        Text(event.date)
                            .font(.system(size: 14, weight: .bold))
                        Text("\u{2022}")
                        Text(event.time)
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundColor(.white.opacity(0.9))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, DNSpace.xl)
            .padding(.bottom, DNSpace.lg)
        }
    }

    private var imagePlaceholder: some View {
        Rectangle()
            .fill(Color.dnMuted.opacity(0.3))
            .overlay(
                Image(systemName: "photo")
                    .font(.system(size: 40))
                    .foregroundColor(.dnTextTertiary)
            )
    }

    // MARK: - Content Section

    private var contentSection: some View {
        VStack(spacing: DNSpace.xl) {
            dateInfoCard
            attendeesSection
            eventDetailsCard
        }
        .padding(DNSpace.xl)
    }

    // MARK: - Date Info Card

    private var dateInfoCard: some View {
        DNCard {
            VStack(alignment: .leading, spacing: DNSpace.md) {
                Text("Date Info")
                    .dnH3()

                HStack(spacing: DNSpace.md) {
                    // Type badge
                    StatusBadge(status: viewModel.dateRequest.dateType == .solo ? "Solo" : "Group")

                    // Status
                    StatusBadge(status: viewModel.statusDisplay)
                }

                // Organizer
                if let organizer = viewModel.dateRequest.organizer {
                    HStack(spacing: DNSpace.md) {
                        AvatarView(
                            url: URL(string: organizer.avatarUrl ?? ""),
                            size: 40
                        )
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Organizer")
                                .dnSmall()
                            Text(organizer.name)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.dnTextPrimary)
                        }
                        Spacer()
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Attendees Section

    private var attendeesSection: some View {
        VStack(alignment: .leading, spacing: DNSpace.md) {
            HStack {
                Text("Attendees")
                    .dnH3()
                Spacer()
                if viewModel.dateRequest.dateType == .group {
                    Button {} label: {
                        HStack(spacing: DNSpace.xs) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 16, weight: .bold))
                            Text("Invite")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundColor(.dnPrimary)
                    }
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DNSpace.md) {
                    ForEach(viewModel.dateRequest.attendees ?? []) { attendee in
                        VStack(spacing: DNSpace.sm) {
                            AvatarView(
                                url: URL(string: attendee.avatarUrl ?? ""),
                                size: 56
                            )
                            Text(attendee.name)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.dnTextPrimary)
                                .frame(width: 56)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Event Details Card

    private var eventDetailsCard: some View {
        DNCard {
            VStack(alignment: .leading, spacing: DNSpace.md) {
                Text("Event Details")
                    .dnH3()

                if let event = viewModel.dateRequest.event {
                    detailRow(icon: "building.2", label: "Venue", value: event.venue)
                    detailRow(icon: "mappin.and.ellipse", label: "Location", value: event.location)
                    detailRow(icon: "clock", label: "Time", value: event.time)
                    detailRow(icon: "dollarsign.circle", label: "Price", value: event.price)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func detailRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: DNSpace.md) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.dnPrimary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(label.uppercased())
                    .dnSmall()
                Text(value)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.dnTextPrimary)
            }
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: DNSpace.md) {
            switch viewModel.dateRequest.status {
            case .open, .full:
                DNButton("Confirm", variant: .primary) {
                    viewModel.confirm()
                }
                DNButton("Cancel", variant: .secondary) {
                    viewModel.cancel()
                }

            case .confirmed:
                DNButton("Open Chat", variant: .primary) {
                    viewModel.openChat()
                }
                Button {
                    viewModel.cancel()
                } label: {
                    Text("CANCEL DATE")
                        .font(.system(size: 16, weight: .bold))
                        .tracking(-0.47)
                        .foregroundColor(.dnDestructive)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: DNRadius.md, style: .continuous)
                                .fill(Color.dnBackground)
                        )
                        .dnNeuRaised(intensity: .heavy, cornerRadius: DNRadius.md)
                }

            case .cancelled:
                EmptyView()
            }
        }
        .padding(.horizontal, DNSpace.xl)
        .padding(.vertical, DNSpace.lg)
        .background(Color.dnBackground)
        .dnNeuRaised(intensity: .medium, cornerRadius: 0)
    }
}
