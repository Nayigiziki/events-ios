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
                        Text("Create a Date")
                            .dnH2()
                            .padding(.top, DNSpace.lg)

                        // Date Type Picker
                        dateTypePicker

                        // Group size (if group selected)
                        if viewModel.dateType == .group {
                            groupSizePicker
                        }

                        // Description
                        VStack(alignment: .leading, spacing: DNSpace.sm) {
                            Text("Description")
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
                            DNButton("Create Date", variant: .primary) {
                                viewModel.createDate()
                                dismiss()
                            }

                            DNButton("Cancel", variant: .secondary) {
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
                            Text(type == .solo ? "Solo Date" : "Group Date")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.dnTextPrimary)
                            Text(type == .solo
                                ? "Meet someone special at this event"
                                : "Bring friends or meet multiple people")
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
            Text("How many people? (including you)")
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
