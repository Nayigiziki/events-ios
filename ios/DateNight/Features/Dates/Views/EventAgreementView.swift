import SwiftUI

struct EventAgreementView: View {
    @StateObject private var viewModel = EventAgreementViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        DNScreen {
            NavigationStack {
                ScrollView {
                    VStack(spacing: DNSpace.xl) {
                        header
                        proposedEventsSection
                        availableEventsSection
                        confirmButton
                    }
                    .padding(.horizontal, DNSpace.lg)
                    .padding(.bottom, DNSpace.xxl * 3)
                }
                .navigationBarHidden(true)
                .overlay {
                    if viewModel.showConfirmation {
                        confirmationOverlay
                    }
                }
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: DNSpace.xs) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.dnTextPrimary)
                        .frame(width: 36, height: 36)
                        .dnNeuRaised(intensity: .light, cornerRadius: DNRadius.full)
                }
                Spacer()
            }

            Text("Choose an Event")
                .font(.system(size: 28, weight: .black))
                .tracking(-0.6)
                .foregroundColor(.dnTextPrimary)
                .padding(.top, DNSpace.sm)

            Text("Propose an event and agree with your match")
                .dnCaption()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, DNSpace.md)
    }

    // MARK: - Proposed Events

    private var proposedEventsSection: some View {
        VStack(alignment: .leading, spacing: DNSpace.md) {
            Text("Proposed Events")
                .dnH3()

            if let myProposal = viewModel.proposedByMe {
                proposalCard(event: myProposal, proposedBy: "You", isOwn: true)
            }

            if let theirProposal = viewModel.proposedByThem {
                proposalCard(event: theirProposal, proposedBy: "Your Match", isOwn: false)
            }

            if viewModel.proposedByMe == nil, viewModel.proposedByThem == nil {
                Text("No proposals yet. Browse events below and propose one!")
                    .dnCaption()
                    .frame(maxWidth: .infinity)
                    .padding(DNSpace.xl)
                    .dnNeuPressed(cornerRadius: DNRadius.lg)
            }
        }
    }

    private func proposalCard(event: Event, proposedBy: String, isOwn: Bool) -> some View {
        DNCard {
            VStack(alignment: .leading, spacing: DNSpace.md) {
                HStack(spacing: DNSpace.md) {
                    AsyncImage(url: URL(string: event.imageUrl ?? "")) { phase in
                        switch phase {
                        case let .success(image):
                            image.resizable().scaledToFill()
                        default:
                            Rectangle().fill(Color.dnMuted)
                        }
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: DNRadius.sm))

                    VStack(alignment: .leading, spacing: DNSpace.xs) {
                        Text(event.title)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.dnTextPrimary)
                        Text("Proposed by \(proposedBy)")
                            .dnSmall()
                    }

                    Spacer()
                }

                if !isOwn {
                    HStack(spacing: DNSpace.md) {
                        DNButton("Accept", variant: .primary) {
                            viewModel.acceptProposal()
                        }
                        DNButton("Reject", variant: .secondary) {
                            viewModel.rejectProposal()
                        }
                    }
                }
            }
        }
    }

    // MARK: - Available Events

    private var availableEventsSection: some View {
        VStack(alignment: .leading, spacing: DNSpace.md) {
            Text("Available Events")
                .dnH3()

            ForEach(viewModel.availableEvents) { event in
                compactEventCard(event: event)
            }
        }
    }

    private func compactEventCard(event: Event) -> some View {
        DNCard {
            HStack(spacing: DNSpace.md) {
                AsyncImage(url: URL(string: event.imageUrl ?? "")) { phase in
                    switch phase {
                    case let .success(image):
                        image.resizable().scaledToFill()
                    default:
                        Rectangle().fill(Color.dnMuted)
                    }
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: DNRadius.sm))

                VStack(alignment: .leading, spacing: DNSpace.xs) {
                    Text(event.title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.dnTextPrimary)
                        .lineLimit(1)

                    HStack(spacing: DNSpace.xs) {
                        Image(systemName: "calendar")
                            .font(.system(size: 11, weight: .bold))
                        Text(event.date)
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(.dnTextSecondary)

                    Text(event.venue)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.dnTextTertiary)
                }

                Spacer()

                let isAlreadyProposed = viewModel.proposedByMe?.id == event.id
                DNButton(isAlreadyProposed ? "Proposed" : "Propose", variant: .secondary) {
                    if !isAlreadyProposed {
                        viewModel.proposeEvent(event)
                    }
                }
                .frame(maxWidth: 110)
                .opacity(isAlreadyProposed ? 0.6 : 1.0)
            }
        }
    }

    // MARK: - Confirm Button

    private var confirmButton: some View {
        Group {
            if viewModel.agreedEvent != nil {
                DNButton("Confirm Date", variant: .primary) {
                    viewModel.confirmDate()
                }
            } else {
                DNButton("Confirm Date", variant: .secondary) {}
                    .opacity(0.5)
                    .allowsHitTesting(false)
            }
        }
        .padding(.top, DNSpace.md)
    }

    // MARK: - Confirmation Overlay

    private var confirmationOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: DNSpace.xl) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 72))
                    .foregroundColor(.dnSuccess)
                    .scaleEffect(viewModel.showConfirmation ? 1.0 : 0.3)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: viewModel.showConfirmation)

                Text("Event Confirmed!")
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(.white)

                if let event = viewModel.agreedEvent {
                    Text(event.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white.opacity(0.8))
                }

                DNButton("Continue", variant: .primary) {
                    viewModel.showConfirmation = false
                }
                .frame(maxWidth: 200)
            }
            .padding(DNSpace.xxl)
        }
        .transition(.opacity)
    }
}
