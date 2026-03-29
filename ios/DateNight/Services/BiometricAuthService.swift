import Foundation
import LocalAuthentication

protocol BiometricAuthServiceProtocol: Sendable {
    func canUseBiometrics() -> Bool
    func authenticate(reason: String) async throws -> Bool
    var isBiometricEnabled: Bool { get }
    func setBiometricEnabled(_ enabled: Bool)
}

final class BiometricAuthService: BiometricAuthServiceProtocol, @unchecked Sendable {
    private let context: LAContext
    private let keychainKey = "datenight_biometric_enabled"

    init(context: LAContext = LAContext()) {
        self.context = context
    }

    func canUseBiometrics() -> Bool {
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    func authenticate(reason: String) async throws -> Bool {
        try await context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: reason
        )
    }

    var isBiometricEnabled: Bool {
        UserDefaults.standard.bool(forKey: keychainKey)
    }

    func setBiometricEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: keychainKey)
    }
}
