import SwiftUI

struct DateRequestCard: View {
    let dateRequest: DateRequest
    var onJoin: (() -> Void)?

    var body: some View {
        NavigationLink {
            DateDetailView(dateRequest: dateRequest)
        } label: {
            cardContent
        }
        .buttonStyle(.plain)
    }

    private var cardContent: some View {
        DNCard(cornerRadius: DNRadius.xxl) {
            VStack(alignment: .leading, spacing: 0) {
                // Event image + info
                if let event = dateRequest.event {
                    ZStack(alignment: .topTrailing) {
                        // Event image
                        DNAsyncImage(url: URL(string: event.imageUrl ?? ""), height: 180, cornerRadius: 0)
                            .overlay(alignment: .bottom) {
                                // Gradient + event info
                                ZStack(alignment: .bottomLeading) {
                                    GradientOverlay(opacity: 0.6)

                                    VStack(alignment: .leading, spacing: DNSpace.xs) {
                                        Text(event.title)
                                            .font(.system(size: 20, weight: .black))
                                            .foregroundColor(.white)

                                        HStack(spacing: DNSpace.xs) {
                                            Image(systemName: "calendar")
                                                .font(.system(size: 12, weight: .bold))
                                            Text(event.date)
                                                .font(.system(size: 13, weight: .bold))
                                        }
                                        .foregroundColor(.white.opacity(0.9))
                                    }
                                    .padding(DNSpace.md)
                                }
                            }

                        // Status badge
                        StatusBadge(status: dateRequest.status.rawValue)
                            .padding(DNSpace.sm)
                    }
                }

                VStack(alignment: .leading, spacing: DNSpace.md) {
                    // Organizer row
                    if let organizer = dateRequest.organizer {
                        HStack(spacing: DNSpace.md) {
                            AvatarView(
                                url: URL(string: organizer.avatarUrl ?? ""),
                                size: 40
                            )

                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(organizer.name), \(organizer.age ?? 0)")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.dnTextPrimary)
                                Text(organizer.bio ?? "")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.dnTextSecondary)
                                    .lineLimit(1)
                            }

                            Spacer()
                        }
                    }

                    // Description
                    Text(dateRequest.description)
                        .dnCaption()
                        .lineLimit(2)

                    // Attendees row
                    if let attendees = dateRequest.attendees, !attendees.isEmpty {
                        DNAttendeeRow(
                            attendees: attendees,
                            maxVisible: 3,
                            avatarSize: 32,
                            showNames: false,
                            label: ""
                        )
                    }

                    // Join button
                    if dateRequest.status == .open {
                        DNButton("ÚNETE A ESTA CITA", variant: .primary) {
                            onJoin?()
                        }
                    } else if dateRequest.status == .full {
                        Text("Esta cita está llena")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.dnTextSecondary)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 44)
                            .dnNeuPressed(cornerRadius: DNRadius.md)
                    }
                }
                .padding(DNSpace.lg)
            }
        }
    }
}
