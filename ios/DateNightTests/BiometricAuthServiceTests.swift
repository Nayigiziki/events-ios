@testable import DateNight
import XCTest

final class MockBiometricAuthService: BiometricAuthServiceProtocol, @unchecked Sendable {
    var canUseBiometricsResult = true
    var authenticateResult: Result<Bool, Error> = .success(true)
    var biometricEnabled = false
    var authenticateCallCount = 0

    func canUseBiometrics() -> Bool { canUseBiometricsResult }

    func authenticate(reason: String) async throws -> Bool {
        authenticateCallCount += 1
        return try authenticateResult.get()
    }

    var isBiometricEnabled: Bool { biometricEnabled }

    func setBiometricEnabled(_ enabled: Bool) {
        biometricEnabled = enabled
    }
}

@MainActor
final class BiometricAuthServiceTests: XCTestCase {
    private var sut: MockBiometricAuthService!

    override func setUp() {
        super.setUp()
        sut = MockBiometricAuthService()
    }

    func testCanUseBiometrics_whenAvailable_returnsTrue() {
        sut.canUseBiometricsResult = true
        XCTAssertTrue(sut.canUseBiometrics())
    }

    func testCanUseBiometrics_whenUnavailable_returnsFalse() {
        sut.canUseBiometricsResult = false
        XCTAssertFalse(sut.canUseBiometrics())
    }

    func testAuthenticate_success_returnsTrue() async throws {
        sut.authenticateResult = .success(true)
        let result = try await sut.authenticate(reason: "Test")
        XCTAssertTrue(result)
        XCTAssertEqual(sut.authenticateCallCount, 1)
    }

    func testAuthenticate_failure_throws() async {
        sut.authenticateResult = .failure(NSError(domain: "LAError", code: -2))
        do {
            _ = try await sut.authenticate(reason: "Test")
            XCTFail("Should have thrown")
        } catch {
            XCTAssertEqual(sut.authenticateCallCount, 1)
        }
    }

    func testBiometricPreference_canBeToggled() {
        XCTAssertFalse(sut.isBiometricEnabled)
        sut.setBiometricEnabled(true)
        XCTAssertTrue(sut.isBiometricEnabled)
        sut.setBiometricEnabled(false)
        XCTAssertFalse(sut.isBiometricEnabled)
    }
}
