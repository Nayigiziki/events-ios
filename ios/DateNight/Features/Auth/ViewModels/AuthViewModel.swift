import Foundation
import SwiftUI

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isFirstLaunch: Bool

    private let firstLaunchKey = "datenight_first_launch_completed"

    init() {
        self.isFirstLaunch = !UserDefaults.standard.bool(forKey: firstLaunchKey)
    }

    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil

        // Mock implementation — simulate network delay
        try? await Task.sleep(nanoseconds: 800_000_000)

        isLoading = false
        isAuthenticated = true
    }

    func signUp(
        email: String,
        password: String,
        name: String,
        birthdate: Date?,
        gender: String?
    ) async {
        isLoading = true
        errorMessage = nil

        // Mock implementation — simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        isLoading = false
        isAuthenticated = true
        isFirstLaunch = true
    }

    func signInWithGoogle() async {
        isLoading = true
        errorMessage = nil

        try? await Task.sleep(nanoseconds: 800_000_000)

        isLoading = false
        isAuthenticated = true
    }

    func signInWithFacebook() async {
        isLoading = true
        errorMessage = nil

        try? await Task.sleep(nanoseconds: 800_000_000)

        isLoading = false
        isAuthenticated = true
    }

    func signOut() {
        isAuthenticated = false
    }

    func checkSession() {
        // Mock: no persisted session
        isAuthenticated = false
    }

    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: firstLaunchKey)
        isFirstLaunch = false
    }
}
