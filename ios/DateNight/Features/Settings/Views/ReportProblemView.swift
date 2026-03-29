import SwiftUI

struct ReportProblemView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var problemDescription = ""
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var showSuccess = false

    var body: some View {
        NavigationStack {
            DNScreen {
                VStack(spacing: DNSpace.lg) {
                    Text("settings_report_description".localized())
                        .dnBody()
                        .foregroundColor(.dnMuted)

                    TextEditor(text: $problemDescription)
                        .frame(minHeight: 120)
                        .padding(DNSpace.sm)
                        .background(Color.dnBackground.opacity(0.5))
                        .cornerRadius(DNRadius.md)

                    if let error = errorMessage {
                        Text(error)
                            .font(.system(size: 14))
                            .foregroundColor(.dnDestructive)
                    }

                    DNButton("button_send".localized(), variant: .primary) {
                        submitReport()
                    }
                    .opacity(isLoading ? 0.6 : 1.0)
                    .disabled(isLoading)

                    Spacer()
                }
                .padding(DNSpace.lg)
            }
            .navigationTitle("settings_report_problem".localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("button_cancel".localized()) { dismiss() }
                }
            }
            .alert("settings_report_sent".localized(), isPresented: $showSuccess) {
                Button("OK") { dismiss() }
            } message: {
                Text("settings_report_thanks".localized())
            }
        }
    }

    private func submitReport() {
        guard !problemDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "settings_problem_required".localized()
            return
        }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                // Stub: send report to backend
                try await Task.sleep(nanoseconds: 1_000_000_000)
                await MainActor.run {
                    isLoading = false
                    showSuccess = true
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
    ReportProblemView()
}
