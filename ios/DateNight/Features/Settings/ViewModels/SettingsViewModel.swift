import Foundation
import Supabase
import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    // Notifications
    @Published var notifyMatches: Bool = true
    @Published var notifyMessages: Bool = true
    @Published var notifyEvents: Bool = true
    @Published var notifyDateReminders: Bool = true
    @Published var notifyFriendRequests: Bool = true

    // Privacy
    @Published var showProfile: Bool = true
    @Published var showDistance: Bool = true
    @Published var showOnlineStatus: Bool = false

    // Preferences
    @Published var selectedLanguage: String = "English"
    @Published var darkModeEnabled: Bool = false

    @Published var isLoading = false
    @Published var errorMessage: String?

    let languages = ["English", "Spanish"]

    private let profileService: any ProfileServiceProtocol
    private let authService: AuthService
    private let languageManager: LanguageManager
    var userId: UUID?

    init(
        profileService: any ProfileServiceProtocol = ProfileService(),
        authService: AuthService? = nil,
        languageManager: LanguageManager = .shared
    ) {
        self.profileService = profileService
        self.authService = authService ?? AuthService()
        self.languageManager = languageManager
        self.userId = self.authService.currentUser?.id
    }

    // MARK: - Settings Persistence

    func loadSettings() {
        guard let userId else { return }

        Task {
            do {
                let profile = try await profileService.fetchProfile(userId: userId)

                // Map language code to display name
                let langCode = languageManager.currentLanguage
                self.selectedLanguage = langCode == "es" ? "Spanish" : "English"

                // Load dark mode preference (stored in AppStorage)
                self.darkModeEnabled = UserDefaults.standard.bool(forKey: "darkModeEnabled")
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func saveSettings() {
        guard let userId else { return }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                // Save language preference
                let langCode = selectedLanguage == "Spanish" ? "es" : "en"
                languageManager.setLanguage(langCode)

                // Save dark mode preference
                UserDefaults.standard.set(darkModeEnabled, forKey: "darkModeEnabled")

                // Save notification/privacy settings to Supabase user metadata
                let metadata: [String: AnyJSON] = [
                    "notify_matches": .bool(notifyMatches),
                    "notify_messages": .bool(notifyMessages),
                    "notify_events": .bool(notifyEvents),
                    "notify_date_reminders": .bool(notifyDateReminders),
                    "notify_friend_requests": .bool(notifyFriendRequests),
                    "show_profile": .bool(showProfile),
                    "show_distance": .bool(showDistance),
                    "show_online_status": .bool(showOnlineStatus)
                ]

                try await authService.updateUserMetadata(metadata)

                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }

    func deleteAccount() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                try await profileService.deleteAccount()
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}
