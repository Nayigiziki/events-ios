import Foundation
import SwiftUI

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var isCheckingSession = false
    @Published var errorMessage: String?
    @Published var isFirstLaunch: Bool
    @Published var showBiometricPrompt = false
    @Published var profileComplete = false
    @Published var userId: UUID?

    private let authService: AuthServiceProtocol
    private let profileService: any ProfileServiceProtocol
    let biometricService: BiometricAuthServiceProtocol
    private let rememberMeService: RememberMeService
    private let firstLaunchKey = "datenight_first_launch_completed"

    init(
        authService: AuthServiceProtocol = SupabaseAuthService(),
        profileService: any ProfileServiceProtocol = ProfileService(),
        biometricService: BiometricAuthServiceProtocol = BiometricAuthService(),
        rememberMeService: RememberMeService = RememberMeService()
    ) {
        self.authService = authService
        self.profileService = profileService
        self.biometricService = biometricService
        self.rememberMeService = rememberMeService
        self.isFirstLaunch = !UserDefaults.standard.bool(forKey: firstLaunchKey)
    }

    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let session = try await authService.signIn(email: email, password: password)
            userId = session.user.id
            isAuthenticated = true
            await checkProfileComplete(userId: session.user.id)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
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

        do {
            _ = try await authService.signUp(email: email, password: password)
            isAuthenticated = true
            isFirstLaunch = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func signInWithGoogle() async {
        isLoading = true
        errorMessage = nil

        do {
            _ = try await authService.signInWithGoogle()
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func signInWithFacebook() async {
        isLoading = true
        errorMessage = nil

        do {
            _ = try await authService.signInWithFacebook()
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func signOut() async {
        do {
            try await authService.signOut()
        } catch {
            // Log but don't block UI
        }
        rememberMeService.save(email: "", enabled: false)
        isAuthenticated = false
    }

    func checkSession() async {
        isCheckingSession = true

        let remembered = rememberMeService.restore()
        guard remembered.enabled else {
            isAuthenticated = false
            isCheckingSession = false
            return
        }

        do {
            if let session = try await authService.checkSession() {
                userId = session.user.id
                if biometricService.isBiometricEnabled, biometricService.canUseBiometrics() {
                    let authenticated = try await biometricService.authenticate(reason: "Unlock DateNight")
                    isAuthenticated = authenticated
                } else {
                    isAuthenticated = true
                }
                if isAuthenticated {
                    await checkProfileComplete(userId: session.user.id)
                }
            } else {
                isAuthenticated = false
            }
        } catch {
            isAuthenticated = false
        }

        isCheckingSession = false
    }

    func checkProfileComplete(userId: UUID) async {
        do {
            let profile = try await profileService.fetchProfile(userId: userId)
            profileComplete = profile.photos.count >= 2
                && profile.bio != nil && !(profile.bio?.isEmpty ?? true)
                && profile.interests.count >= 3
        } catch {
            profileComplete = false
        }
    }

    func enableBiometrics() {
        biometricService.setBiometricEnabled(true)
    }

    func disableBiometrics() {
        biometricService.setBiometricEnabled(false)
    }

    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: firstLaunchKey)
        isFirstLaunch = false
    }
}
