import Foundation
import SwiftUI

/// In-app language toggle between English and Spanish.
/// Stores preference in UserDefaults and forces bundle to load the selected .lproj.
final class LanguageManager: ObservableObject {
    static let shared = LanguageManager()

    @AppStorage("appLanguage") var currentLanguage: String = "en" {
        didSet { applyLanguage() }
    }

    var bundle: Bundle = .main

    private init() {
        applyLanguage()
    }

    func toggle() {
        currentLanguage = currentLanguage == "en" ? "es" : "en"
    }

    func setLanguage(_ code: String) {
        currentLanguage = code
    }

    var isSpanish: Bool { currentLanguage == "es" }
    var displayName: String { currentLanguage == "en" ? "English" : "Español" }

    private func applyLanguage() {
        let path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj")
        bundle = path.flatMap { Bundle(path: $0) } ?? .main
        objectWillChange.send()
    }
}

// MARK: - Localized String Helper

extension String {
    /// Look up a key in the user's chosen language bundle (not the device locale).
    func localized() -> String {
        LanguageManager.shared.bundle.localizedString(forKey: self, value: nil, table: nil)
    }
}
