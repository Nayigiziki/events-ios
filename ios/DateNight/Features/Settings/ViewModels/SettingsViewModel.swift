import Foundation

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

    let languages = ["English", "Spanish"]

    func logout() {
        // Mock logout
    }

    func deleteAccount() {
        // Mock delete
    }
}
