import SwiftUI

struct EmailSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var newEmail = ""
    @State private var errorMessage: String?
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            DNScreen {
                VStack(spacing: DNSpace.lg) {
                    Text("settings_email_description".localized())
                        .dnBody()
                        .foregroundColor(.dnMuted)

                    DNTextField(
                        placeholder: "settings_new_email".localized(),
                        text: $newEmail
                    )

                    if let error = errorMessage {
                        Text(error)
                            .font(.system(size: 14))
                            .foregroundColor(.dnDestructive)
                    }

                    DNButton("button_save".localized(), variant: .primary) {
                        updateEmail()
                    }
                    .opacity(isLoading ? 0.6 : 1.0)
                    .disabled(isLoading)

                    Spacer()
                }
                .padding(DNSpace.lg)
            }
            .navigationTitle("settings_email".localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("button_cancel".localized()) { dismiss() }
                }
            }
        }
    }

    private func updateEmail() {
        guard !newEmail.isEmpty else {
            errorMessage = "settings_email_required".localized()
            return
        }

        guard newEmail.contains("@") else {
            errorMessage = "settings_invalid_email".localized()
            return
        }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                // Stub: email change via AuthService
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
    EmailSettingsView()
}
