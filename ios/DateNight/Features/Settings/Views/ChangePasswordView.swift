import SwiftUI

struct ChangePasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            DNScreen {
                VStack(spacing: DNSpace.lg) {
                    VStack(spacing: DNSpace.md) {
                        DNTextField(
                            placeholder: "settings_current_password".localized(),
                            text: $currentPassword,
                            isSecure: true
                        )

                        DNTextField(
                            placeholder: "settings_new_password".localized(),
                            text: $newPassword,
                            isSecure: true
                        )

                        DNTextField(
                            placeholder: "settings_confirm_password".localized(),
                            text: $confirmPassword,
                            isSecure: true
                        )
                    }

                    if let error = errorMessage {
                        Text(error)
                            .font(.system(size: 14))
                            .foregroundColor(.dnDestructive)
                    }

                    DNButton("button_save".localized(), variant: .primary) {
                        changePassword()
                    }
                    .opacity(isLoading ? 0.6 : 1.0)
                    .disabled(isLoading)

                    Spacer()
                }
                .padding(DNSpace.lg)
            }
            .navigationTitle("settings_change_password".localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("button_cancel".localized()) { dismiss() }
                }
            }
        }
    }

    private func changePassword() {
        guard newPassword == confirmPassword else {
            errorMessage = "settings_passwords_dont_match".localized()
            return
        }

        guard newPassword.count >= 8 else {
            errorMessage = "settings_password_too_short".localized()
            return
        }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                // Stub: password change via AuthService
                try await Task.sleep(nanoseconds: 1_000_000_000)
                await MainActor.run {
                    isLoading = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    ChangePasswordView()
}
