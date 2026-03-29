import SwiftUI

struct ForgotPasswordView: View {
    @StateObject private var viewModel = ForgotPasswordViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        DNScreen {
            ScrollView {
                VStack(spacing: DNSpace.xxl) {
                    // MARK: - Header Icon + Title

                    VStack(spacing: DNSpace.lg) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 32, weight: .regular))
                            .foregroundColor(.white)
                            .frame(width: 64, height: 64)
                            .background(
                                RoundedRectangle(cornerRadius: DNRadius.lg, style: .continuous)
                                    .fill(Color.dnPrimary)
                            )
                            .dnNeuCTAButton(cornerRadius: DNRadius.lg)

                        Text("forgot_password_title".localized())
                            .dnH2()

                        Text("forgot_password_subtitle".localized())
                            .dnBody()
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, DNSpace.lg)
                    }
                    .padding(.top, DNSpace.xxl)

                    if viewModel.isSuccess {
                        // MARK: - Success State

                        successView
                    } else {
                        // MARK: - Form

                        formView
                    }
                }
                .padding(.horizontal, DNSpace.xl)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.dnTextPrimary)
                        .frame(width: 44, height: 44)
                        .dnNeuRaised(intensity: .medium, cornerRadius: DNRadius.sm)
                }
            }
        }
        .overlay {
            if viewModel.isLoading {
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                ProgressView()
                    .tint(.dnPrimary)
                    .scaleEffect(1.5)
            }
        }
    }

    // MARK: - Form View

    private var formView: some View {
        VStack(spacing: DNSpace.lg) {
            // Email field
            VStack(alignment: .leading, spacing: DNSpace.sm) {
                Text("forgot_password_email".localized())
                    .dnLabel()
                    .textCase(.uppercase)

                DNTextField(
                    placeholder: "email@example.com",
                    text: $viewModel.email,
                    icon: "envelope"
                )
            }

            // Error message
            if let error = viewModel.errorMessage {
                HStack(spacing: DNSpace.sm) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.dnDestructive)

                    Text(error)
                        .dnCaption()
                        .foregroundColor(.dnDestructive)
                }
                .padding(DNSpace.lg)
                .frame(maxWidth: .infinity)
                .dnNeuPressed(intensity: .light, cornerRadius: DNRadius.md)
            }

            // Send Reset Link button
            DNButton("forgot_password_send".localized(), variant: .primary) {
                Task {
                    await viewModel.sendResetLink()
                }
            }
            .padding(.top, DNSpace.sm)
        }
    }

    // MARK: - Success View

    private var successView: some View {
        VStack(spacing: DNSpace.lg) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 56, weight: .medium))
                .foregroundColor(.dnSuccess)

            Text("forgot_password_check_email".localized())
                .dnH3()

            Text(String(format: "forgot_password_sent_message".localized(), viewModel.email))
                .dnBody()
                .multilineTextAlignment(.center)
                .padding(.horizontal, DNSpace.lg)

            DNButton("forgot_password_back_to_login".localized(), variant: .secondary) {
                dismiss()
            }
            .padding(.top, DNSpace.md)
        }
        .padding(.top, DNSpace.lg)
    }
}

#Preview {
    NavigationStack {
        ForgotPasswordView()
    }
}
