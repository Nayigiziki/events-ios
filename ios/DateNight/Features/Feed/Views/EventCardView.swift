import SwiftUI

struct EventCardView: View {
    let event: Event
    let isLiked: Bool
    let onToggleLike: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header: category + venue + attendee count
            HStack {
                HStack(spacing: DNSpace.md) {
                    categoryBadge
                    Text(event.venue)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.dnTextPrimary)
                }
                Spacer()
                HStack(spacing: DNSpace.xs) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.dnPrimary)
                    Text("\(event.attendees?.count ?? 0)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.dnPrimary)
                }
            }
            .padding(.horizontal, DNSpace.xl)
            .padding(.vertical, DNSpace.lg)

            // Event image with like button
            ZStack(alignment: .topTrailing) {
                eventImage
                likeButton
                    .padding(DNSpace.lg)
                    .padding(.trailing, DNSpace.xs)
            }
            .padding(.horizontal, DNSpace.lg)

            // Details
            VStack(alignment: .leading, spacing: DNSpace.md) {
                Text(event.title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.dnTextPrimary)

                // Date + time row
                HStack(spacing: DNSpace.md) {
                    Image(systemName: "calendar")
                        .foregroundColor(.dnPrimary)
                    Text(event.date)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.dnTextPrimary)
                    Text("\u{00B7}")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.dnTextSecondary)
                    Image(systemName: "clock")
                        .foregroundColor(.dnPrimary)
                    Text(event.time)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.dnTextPrimary)
                }
                .padding(DNSpace.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
                .dnNeuPressed(cornerRadius: DNRadius.md)

                // Location row
                HStack(spacing: DNSpace.md) {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(.dnPrimary)
                    Text(event.location)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.dnTextPrimary)
                }
                .padding(DNSpace.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
                .dnNeuPressed(cornerRadius: DNRadius.md)

                // Attendees
                attendeesSection

                // Description
                Text(event.description)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.dnTextSecondary)
                    .lineSpacing(4)

                // CTA button
                NavigationLink(value: event) {
                    Text("Ver Detalles")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .textCase(.uppercase)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DNSpace.xl)
                        .background(
                            RoundedRectangle(cornerRadius: DNRadius.md, style: .continuous)
                                .fill(Color.dnPrimary)
                        )
                        .dnNeuButton(cornerRadius: DNRadius.md)
                }
                .buttonStyle(.plain)
            }
            .padding(DNSpace.xl)
        }
        .dnNeuRaised(intensity: .extraHeavy, cornerRadius: DNRadius.xxl)
    }

    // MARK: - Subviews

    private var categoryBadge: some View {
        Text(event.category.uppercased())
            .font(.system(size: 11, weight: .heavy))
            .tracking(0.8)
            .foregroundColor(.white)
            .padding(.horizontal, DNSpace.lg)
            .padding(.vertical, DNSpace.sm)
            .background(
                Capsule()
                    .fill(categoryColor(for: event.category))
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 2, y: 2)
            )
    }

    private var eventImage: some View {
        AsyncImage(url: URL(string: event.imageUrl ?? "")) { phase in
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
        .aspectRatio(4 / 3, contentMode: .fill)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: DNRadius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DNRadius.md, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.3)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        )
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

    private var likeButton: some View {
        Button {
            onToggleLike()
        } label: {
            Image(systemName: isLiked ? "heart.fill" : "heart")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(isLiked ? .white : .dnAccentPink)
                .frame(width: 52, height: 52)
                .background(
                    Circle()
                        .fill(isLiked ? Color.dnAccentPink : Color.dnBackground)
                )
        }
        .buttonStyle(.plain)
        .shadow(
            color: isLiked ? .clear : Color(hex: "a3b1c6").opacity(0.15),
            radius: 8, x: 4, y: 4
        )
        .shadow(
            color: isLiked ? .clear : Color.white.opacity(0.8),
            radius: 8, x: -4, y: -4
        )
        .animation(.dnButtonPress, value: isLiked)
    }

    private var attendeesSection: some View {
        VStack(alignment: .leading, spacing: DNSpace.md) {
            Text("Asistiendo")
                .font(.system(size: 12, weight: .bold))
                .textCase(.uppercase)
                .tracking(0.8)
                .foregroundColor(.dnTextSecondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DNSpace.md) {
                    ForEach((event.attendees ?? []).prefix(5)) { user in
                        VStack(spacing: DNSpace.xs) {
                            AvatarView(
                                url: URL(string: user.avatarUrl ?? ""),
                                size: 56
                            )
                            Text(user.name.components(separatedBy: " ").first ?? user.name)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.dnTextPrimary)
                        }
                    }
                    if (event.attendees?.count ?? 0) > 5 {
                        VStack(spacing: DNSpace.xs) {
                            ZStack {
                                Circle()
                                    .fill(Color.dnBackground)
                                    .frame(width: 56, height: 56)
                                    .dnNeuRaised(cornerRadius: DNRadius.full)
                                Text("+\((event.attendees?.count ?? 0) - 5)")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.dnPrimary)
                            }
                            Text("More")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.dnTextPrimary)
                        }
                    }
                }
            }
        }
        .padding(.bottom, DNSpace.sm)
    }

    // MARK: - Helpers

    private func categoryColor(for category: String) -> Color {
        switch category {
        case "Music": .dnPrimary
        case "Art": .dnAccentPink
        case "Comedy": .dnWarning
        case "Food": .dnSuccess
        case "Wellness": .dnInfo
        case "Wine": .dnDestructive
        case "Social": Color(hex: "0984e3")
        default: .dnPrimary
        }
    }
}
