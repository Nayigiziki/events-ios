import SwiftUI

struct CreateDateSheet: View {
    @ObservedObject var viewModel: EventDetailViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            DNScreen {
                ScrollView {
                    VStack(alignment: .leading, spacing: DNSpace.xl) {
                        // Header
                        Text("create_date_title".localized())
                            .dnH2()
                            .padding(.top, DNSpace.lg)

                        // Date Type Picker
                        dateTypePicker

                        // Group size (if group selected)
                        if viewModel.dateType == .group {
                            groupSizePicker
                        }

                        // Invite Friends
                        inviteFriendsSection

                        // Description
                        VStack(alignment: .leading, spacing: DNSpace.sm) {
                            Text("create_date_description".localized())
                                .dnCaption()
                            TextEditor(text: $viewModel.dateDescription)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.dnTextPrimary)
                                .frame(minHeight: 80)
                                .padding(DNSpace.md)
                                .dnNeuPressed(cornerRadius: DNRadius.md)
                                .scrollContentBackground(.hidden)
                        }

                        // Buttons
                        VStack(spacing: DNSpace.md) {
                            DNButton("create_date_button".localized(), variant: .primary) {
                                Task {
                                    await viewModel.createDate()
                                    dismiss()
                                }
                            }

                            DNButton("create_date_cancel".localized(), variant: .secondary) {
                                dismiss()
                            }
                        }
                    }
                    .padding(.horizontal, DNSpace.xl)
                    .padding(.bottom, DNSpace.xxl)
                }
            }
            .navigationBarHidden(true)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .task {
            await viewModel.loadInvitableUsers()
        }
    }

    // MARK: - Invite Friends

    private var inviteFriendsSection: some View {
        VStack(alignment: .leading, spacing: DNSpace.md) {
            Text("create_date_invite_friends".localized())
                .font(.system(size: 13, weight: .bold))
                .textCase(.uppercase)
                .tracking(0.5)
                .foregroundColor(.dnTextSecondary)

            if viewModel.invitableUsers.isEmpty {
                Text("create_date_no_friends".localized())
                    .dnCaption()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DNSpace.md) {
                        ForEach(viewModel.invitableUsers) { user in
                            let isInvited = viewModel.invitedUserIds.contains(user.id)
                            Button {
                                withAnimation(.dnButtonPress) {
                                    viewModel.toggleInvite(user.id)
                                }
                            } label: {
                                VStack(spacing: DNSpace.xs) {
                                    ZStack(alignment: .bottomTrailing) {
                                        AvatarView(
                                            url: URL(string: user.avatarUrl ?? ""),
                                            size: 48
                                        )
                                        if isInvited {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(.dnSuccess)
                                                .background(Circle().fill(Color.dnBackground).frame(
                                                    width: 18,
                                                    height: 18
                                                ))
                                        }
                                    }
                                    Text(user.name)
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(isInvited ? .dnPrimary : .dnTextSecondary)
                                        .lineLimit(1)
                                        .frame(width: 56)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Date Type Picker

    private var dateTypePicker: some View {
        VStack(spacing: DNSpace.md) {
            ForEach(EventDetailViewModel.DateType.allCases, id: \.self) { type in
                let isSelected = viewModel.dateType == type
                Button {
                    withAnimation(.dnButtonPress) {
                        viewModel.dateType = type
                    }
                } label: {
                    HStack(spacing: DNSpace.md) {
                        ZStack {
                            Circle()
                                .fill(isSelected ? Color.dnAccentPink : Color.dnPrimary)
                                .frame(width: 40, height: 40)
                            Image(systemName: type == .solo ? "heart.fill" : "person.2.fill")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }

                        VStack(alignment: .leading, spacing: DNSpace.xs) {
                            Text(type == .solo ? "create_date_solo".localized() : "create_date_group".localized())
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.dnTextPrimary)
                            Text(type == .solo
                                ? "create_date_solo_desc".localized()
                                : "create_date_group_desc".localized())
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.dnTextSecondary)
                        }
                        Spacer()
                    }
                    .padding(DNSpace.lg)
                }
                .buttonStyle(.plain)
                .modifier(DateTypeModifier(isSelected: isSelected))
                .animation(.dnButtonPress, value: isSelected)
            }
        }
    }

    // MARK: - Group Size Picker

    private var groupSizePicker: some View {
        VStack(alignment: .leading, spacing: DNSpace.md) {
            Text("create_date_group_size".localized())
                .font(.system(size: 13, weight: .bold))
                .textCase(.uppercase)
                .tracking(0.5)
                .foregroundColor(.dnTextSecondary)

            HStack(spacing: DNSpace.sm) {
                ForEach(2 ... 6, id: \.self) { size in
                    let isSelected = viewModel.groupSize == size
                    Button {
                        withAnimation(.dnButtonPress) {
                            viewModel.groupSize = size
                        }
                    } label: {
                        Text("\(size)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(isSelected ? .white : .dnTextPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, DNSpace.md)
                            .background(
                                Group {
                                    if isSelected {
                                        RoundedRectangle(cornerRadius: DNRadius.sm, style: .continuous)
                                            .fill(Color.dnPrimary)
                                    }
                                }
                            )
                    }
                    .buttonStyle(.plain)
                    .modifier(GroupSizeModifier(isSelected: isSelected))
                }
            }
        }
    }
}

// MARK: - Modifiers

private struct DateTypeModifier: ViewModifier {
    let isSelected: Bool

    func body(content: Content) -> some View {
        if isSelected {
            content.dnNeuPressed(cornerRadius: DNRadius.md)
        } else {
            content.dnNeuRaised(cornerRadius: DNRadius.md)
        }
    }
}

private struct GroupSizeModifier: ViewModifier {
    let isSelected: Bool

    func body(content: Content) -> some View {
        if isSelected {
            content.dnNeuPressed(cornerRadius: DNRadius.sm)
        } else {
            content.dnNeuRaised(cornerRadius: DNRadius.sm)
        }
    }
}
