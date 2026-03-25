import Foundation
import SwiftUI

@MainActor
final class ForgotPasswordViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var isLoading: Bool = false
    @Published var isSuccess: Bool = false
    @Published var errorMessage: String?

    func sendResetLink() async {
        guard !email.isEmpty else {
            errorMessage = "Please enter your email address."
            return
        }

        isLoading = true
        errorMessage = nil

        // Mock implementation — simulate network delay
        try? await Task.sleep(nanoseconds: 1_500_000_000)

        // FUTURE: Replace with AuthService.resetPassword(email:) when backend is ready
        print("[ForgotPasswordViewModel] Reset link sent to: \(email)")

        isLoading = false
        isSuccess = true
    }
}
