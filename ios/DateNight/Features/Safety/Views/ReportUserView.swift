import SwiftUI

struct ReportUserView: View {
    @StateObject private var viewModel: ReportUserViewModel
    @Environment(\.dismiss) private var dismiss

    init(reportedUser: UserProfile) {
        _viewModel = StateObject(wrappedValue: ReportUserViewModel(reportedUser: reportedUser))
    }

    var body: some View {
        DNScreen {
            ScrollView {
                VStack(spacing: DNSpace.xl) {
                    Spacer().frame(height: DNSpace.lg)

                    Text("report_title".localized())
                        .dnH2()

                    AvatarView(
                        url: URL(string: viewModel.reportedUser.avatarUrl ?? ""),
                        size: 72
                    )

                    Text(viewModel.reportedUser.name)
                        .dnH3()

                    // Reason picker
                    Text("report_reason".localized())
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
                    Text("report_additional_details".localized())
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
                                Text("report_details_placeholder".localized())
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
                            Text("report_block_and_report".localized())
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

                        DNButton("button_cancel".localized(), variant: .secondary) {
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
