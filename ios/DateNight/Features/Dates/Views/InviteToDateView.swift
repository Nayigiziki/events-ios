import SwiftUI

struct InviteToDateView: View {
    @StateObject private var viewModel = InviteToDateViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        DNScreen {
            NavigationStack {
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: DNSpace.xl) {
                            header
                            selectedInviteesSection

                            if viewModel.isLoading {
                                ProgressView()
                                    .padding(.top, DNSpace.xxl)
                            } else {
                                matchesSection
                                friendsSection
                            }
                        }
                        .padding(.horizontal, DNSpace.lg)
                        .padding(.bottom, 120)
                    }

                    sendButton
                }
                .navigationBarHidden(true)
            }
        }
        .task {
            await viewModel.loadData()
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

            Text("invite_title".localized())
                .font(.system(size: 28, weight: .black))
                .tracking(-0.6)
                .foregroundColor(.dnTextPrimary)
                .padding(.top, DNSpace.sm)

            Text("invite_subtitle".localized())
                .dnCaption()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, DNSpace.md)
    }

    // MARK: - Selected Invitees

    private var selectedInviteesSection: some View {
        Group {
            if !viewModel.selectedInvitees.isEmpty {
                VStack(alignment: .leading, spacing: DNSpace.md) {
                    Text(String(format: "invite_selected".localized(), viewModel.selectedInvitees.count))
                        .dnLabel()

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: DNSpace.sm) {
                            ForEach(viewModel.selectedInvitees, id: \.id) { user in
                                selectedChip(user: user)
                            }
                        }
                    }
                }
            }
        }
    }

    private func selectedChip(user: UserProfile) -> some View {
        HStack(spacing: DNSpace.sm) {
            AvatarView(url: URL(string: user.avatarUrl ?? ""), size: 24)

            Text(user.name)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)

            Button {
                withAnimation(.dnButtonPress) {
                    viewModel.toggleInvitee(user)
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.horizontal, DNSpace.md)
        .padding(.vertical, DNSpace.sm)
        .background(
            Capsule().fill(Color.dnPrimary)
        )
    }

    // MARK: - Matches Section

    private var matchesSection: some View {
        VStack(alignment: .leading, spacing: DNSpace.md) {
            Text("invite_from_matches".localized())
                .dnH3()

            ForEach(viewModel.matches, id: \.id) { user in
                inviteeRow(user: user)
            }
        }
    }

    // MARK: - Friends Section

    private var friendsSection: some View {
        VStack(alignment: .leading, spacing: DNSpace.md) {
            Text("invite_from_friends".localized())
                .dnH3()

            ForEach(viewModel.friends, id: \.id) { user in
                inviteeRow(user: user)
            }
        }
    }

    private func inviteeRow(user: UserProfile) -> some View {
        let isSelected = viewModel.isSelected(user)

        return DNCard {
            HStack(spacing: DNSpace.md) {
                AvatarView(url: URL(string: user.avatarUrl ?? ""), size: 48)

                VStack(alignment: .leading, spacing: 2) {
                    Text(user.name)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.dnTextPrimary)
                    Text(user.bio ?? "")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.dnTextSecondary)
                        .lineLimit(1)
                }

                Spacer()

                Button {
                    withAnimation(.dnButtonPress) {
                        viewModel.toggleInvitee(user)
                    }
                } label: {
                    Text(isSelected ? "invite_invited".localized() : "button_invite".localized())
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(isSelected ? .white : .dnPrimary)
                        .padding(.horizontal, DNSpace.lg)
                        .padding(.vertical, DNSpace.sm)
                        .background(
                            Capsule()
                                .fill(isSelected ? Color.dnPrimary : Color.clear)
                        )
                        .overlay(
                            Capsule()
                                .stroke(Color.dnPrimary, lineWidth: isSelected ? 0 : 2)
                        )
                }
            }
        }
    }

    // MARK: - Send Button

    private var sendButton: some View {
        VStack {
            if viewModel.isSending {
                ProgressView()
                    .padding()
            } else {
                DNButton(
                    viewModel.selectedInvitees.isEmpty
                        ? "invite_select_people".localized()
                        : String(format: "invite_send_count".localized(), viewModel.selectedInvitees.count),
                    variant: .primary
                ) {
                    Task { await viewModel.sendInvitations() }
                }
                .opacity(viewModel.selectedInvitees.isEmpty ? 0.5 : 1.0)
                .allowsHitTesting(!viewModel.selectedInvitees.isEmpty)
            }
        }
        .padding(.horizontal, DNSpace.xl)
        .padding(.vertical, DNSpace.lg)
        .background(Color.dnBackground)
        .dnNeuRaised(intensity: .medium, cornerRadius: 0)
    }
}
