import Foundation

struct RememberMeResult {
    let email: String
    let enabled: Bool
}

struct RememberMeService {
    private let defaults: UserDefaults
    private let emailKey = "datenight_remember_me_email"
    private let enabledKey = "datenight_remember_me_enabled"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func save(email: String, enabled: Bool) {
        if enabled {
            defaults.set(email, forKey: emailKey)
            defaults.set(true, forKey: enabledKey)
        } else {
            defaults.removeObject(forKey: emailKey)
            defaults.set(false, forKey: enabledKey)
        }
    }

    func restore() -> RememberMeResult {
        let enabled = defaults.bool(forKey: enabledKey)
        let email = enabled ? (defaults.string(forKey: emailKey) ?? "") : ""
        return RememberMeResult(email: email, enabled: enabled)
    }
}
