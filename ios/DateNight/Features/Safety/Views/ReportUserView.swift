import SwiftUI

struct ReportUserView: View {
    @StateObject private var viewModel: ReportUserViewModel
    @Environment(\.dismiss) private var dismiss

    init(reportedUser: MockUser) {
        _viewModel = StateObject(wrappedValue: ReportUserViewModel(reportedUser: reportedUser))
    }

    var body: some View {
        DNScreen {
            ScrollView {
                VStack(spacing: DNSpace.xl) {
                    Spacer().frame(height: DNSpace.lg)

                    Text("REPORT USER")
                        .dnH2()

                    AvatarView(
                        url: URL(string: viewModel.reportedUser.avatar),
                        size: 72
                    )

                    Text(viewModel.reportedUser.name)
                        .dnH3()

                    // Reason picker
                    Text("REASON")
                        .dnLabel()
                        .frame(maxWidth: .infinity, alignment: .leading)

                    DNCard {
                        VStack(spacing: DNSpace.sm) {
                            ForEach(viewModel.reasons, id: \.self) { reason in
                                reasonRow(reason)
                            }
                        }
                    }

                    // Additional details
                    Text("ADDITIONAL DETAILS")
                        .dnLabel()
                        .frame(maxWidth: .infinity, alignment: .leading)

                    TextEditor(text: $viewModel.additionalDetails)
                        .font(.system(size: 16, weight: .semibold))
                        .tracking(-0.47)
                        .foregroundColor(.dnTextPrimary)
                        .frame(height: 100)
                        .padding(DNSpace.md)
                        .scrollContentBackground(.hidden)
                        .background(Color.dnBackground)
                        .dnNeuPressed(intensity: .medium, cornerRadius: DNRadius.md)
                        .overlay(alignment: .topLeading) {
                            if viewModel.additionalDetails.isEmpty {
                                Text("Provide more details...")
                                    .font(.system(size: 16, weight: .semibold))
                                    .tracking(-0.47)
                                    .foregroundColor(.dnTextTertiary)
                                    .padding(.horizontal, DNSpace.lg)
                                    .padding(.top, DNSpace.lg)
                                    .allowsHitTesting(false)
                            }
                        }

                    // Buttons
                    VStack(spacing: DNSpace.md) {
                        Button {
                            Task {
                                await viewModel.blockUser()
                                await viewModel.submitReport()
                                dismiss()
                            }
                        } label: {
                            Text("BLOCK & REPORT")
                                .font(.system(size: 20, weight: .bold))
                                .tracking(0.05)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 76)
                                .background(
                                    RoundedRectangle(cornerRadius: DNRadius.md, style: .continuous)
                                        .fill(Color.dnDestructive)
                                )
                                .dnNeuCTAButton(cornerRadius: DNRadius.md)
                        }
                        .opacity(viewModel.selectedReason.isEmpty ? 0.5 : 1.0)
                        .disabled(viewModel.selectedReason.isEmpty)

                        DNButton("Cancel", variant: .secondary) {
                            dismiss()
                        }
                    }

                    Spacer().frame(height: DNSpace.xxl)
                }
                .padding(.horizontal, DNSpace.lg)
            }
        }
    }

    private func reasonRow(_ reason: String) -> some View {
        Button {
            viewModel.selectedReason = reason
        } label: {
            HStack(spacing: DNSpace.md) {
                ZStack {
                    Circle()
                        .stroke(
                            viewModel.selectedReason == reason ? Color.dnDestructive : Color.dnMuted,
                            lineWidth: 2
                        )
                        .frame(width: 22, height: 22)

                    if viewModel.selectedReason == reason {
                        Circle()
                            .fill(Color.dnDestructive)
                            .frame(width: 12, height: 12)
                    }
                }

                Text(reason)
                    .dnBody()

                Spacer()
            }
            .padding(.vertical, DNSpace.xs)
        }
    }
}

#Preview {
    ReportUserView(reportedUser: MockData.users[0])
}
