import SwiftUI

struct EventCardView: View {
    let event: Event
    let isLiked: Bool
    let onToggleLike: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                HStack(spacing: DNSpace.md) {
                    DNCategoryBadge(category: event.category)
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

            // Image + like
            ZStack(alignment: .topTrailing) {
                DNAsyncImage(url: URL(string: event.imageUrl ?? ""), height: 200, cornerRadius: DNRadius.md)
                DNLikeButton(isLiked: isLiked, action: onToggleLike)
                    .padding(DNSpace.lg)
            }
            .padding(.horizontal, DNSpace.lg)

            // Details
            VStack(alignment: .leading, spacing: DNSpace.md) {
                Text(event.title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.dnTextPrimary)

                DNInfoPill(icon: "calendar", text: "\(event.date)  \u{00B7}  \(event.time)")
                DNInfoPill(icon: "mappin.and.ellipse", text: event.location)

                DNAttendeeRow(attendees: event.attendees ?? [], avatarSize: 48)

                Text(event.description)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.dnTextSecondary)
                    .lineLimit(2)

                NavigationLink(value: event) {
                    Text("Ver Detalles")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .textCase(.uppercase)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: DNRadius.md, style: .continuous)
                                .fill(Color.dnPrimary)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(DNSpace.xl)
        }
        .dnNeuRaised(intensity: .heavy, cornerRadius: DNRadius.xxl)
    }
}
