@testable import DateNight
import XCTest

@MainActor
final class AuthViewModelTests: XCTestCase {
    private var sut: AuthViewModel!
    private var mockAuth: MockAuthService!
    private var mockBiometric: MockBiometricAuthService!
    private var mockProfile: MockProfileService!

    override func setUp() {
        super.setUp()
        mockAuth = MockAuthService()
        mockBiometric = MockBiometricAuthService()
        mockProfile = MockProfileService()
        sut = AuthViewModel(authService: mockAuth, profileService: mockProfile, biometricService: mockBiometric)
    }

    override func tearDown() {
        sut = nil
        mockAuth = nil
        mockBiometric = nil
        mockProfile = nil
        super.tearDown()
    }

    // MARK: - Sign In

    func testSignIn_success_setsIsAuthenticated() async {
        await sut.signIn(email: "test@test.com", password: "password")

        XCTAssertTrue(sut.isAuthenticated)
        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
        XCTAssertEqual(mockAuth.signInCallCount, 1)
    }

    func testSignIn_failure_setsErrorMessage() async {
        mockAuth.signInResult = .failure(NSError(
            domain: "test",
            code: 401,
            userInfo: [NSLocalizedDescriptionKey: "Invalid credentials"]
        ))

        await sut.signIn(email: "test@test.com", password: "wrong")

        XCTAssertFalse(sut.isAuthenticated)
        XCTAssertEqual(sut.errorMessage, "Invalid credentials")
        XCTAssertFalse(sut.isLoading)
    }

    // MARK: - Sign Up

    func testSignUp_success_setsIsAuthenticated() async {
        await sut.signUp(email: "new@test.com", password: "password123", name: "Test", birthdate: nil, gender: nil)

        XCTAssertTrue(sut.isAuthenticated)
        XCTAssertTrue(sut.isFirstLaunch)
        XCTAssertNil(sut.errorMessage)
        XCTAssertEqual(mockAuth.signUpCallCount, 1)
    }

    func testSignUp_failure_setsErrorMessage() async {
        mockAuth.signUpResult = .failure(NSError(
            domain: "test",
            code: 400,
            userInfo: [NSLocalizedDescriptionKey: "Email taken"]
        ))

        await sut.signUp(email: "taken@test.com", password: "password", name: "Test", birthdate: nil, gender: nil)

        XCTAssertFalse(sut.isAuthenticated)
        XCTAssertEqual(sut.errorMessage, "Email taken")
    }

    // MARK: - Sign Out

    func testSignOut_success_clearsAuthentication() async {
        await sut.signIn(email: "test@test.com", password: "password")
        XCTAssertTrue(sut.isAuthenticated)

        await sut.signOut()

        XCTAssertFalse(sut.isAuthenticated)
        XCTAssertEqual(mockAuth.signOutCallCount, 1)
    }

    // MARK: - Check Session

    func testCheckSession_withExistingSession_setsAuthenticated() async {
        mockAuth.checkSessionResult = AuthSession(
            user: AuthUser(id: UUID(), email: "test@test.com"),
            accessToken: "token"
        )

        await sut.checkSession()

        XCTAssertTrue(sut.isAuthenticated)
        XCTAssertEqual(mockAuth.checkSessionCallCount, 1)
    }

    func testCheckSession_withNoSession_remainsUnauthenticated() async {
        mockAuth.checkSessionResult = nil

        await sut.checkSession()

        XCTAssertFalse(sut.isAuthenticated)
    }

    // MARK: - OAuth

    func testSignInWithGoogle_success_setsAuthenticated() async {
        await sut.signInWithGoogle()

        XCTAssertTrue(sut.isAuthenticated)
        XCTAssertFalse(sut.isLoading)
    }

    func testSignInWithFacebook_success_setsAuthenticated() async {
        await sut.signInWithFacebook()

        XCTAssertTrue(sut.isAuthenticated)
        XCTAssertFalse(sut.isLoading)
    }

    // MARK: - Loading State

    func testCheckSession_setsIsCheckingSession() async {
        XCTAssertFalse(sut.isCheckingSession)

        await sut.checkSession()

        XCTAssertFalse(sut.isCheckingSession)
        XCTAssertEqual(mockAuth.checkSessionCallCount, 1)
    }

    // MARK: - Biometric Auth

    func testCheckSession_withBiometricEnabled_promptsBiometric() async {
        mockAuth.checkSessionResult = AuthSession(
            user: AuthUser(id: UUID(), email: "test@test.com"),
            accessToken: "token"
        )
        mockBiometric.canUseBiometricsResult = true
        mockBiometric.biometricEnabled = true
        mockBiometric.authenticateResult = .success(true)

        await sut.checkSession()

        XCTAssertTrue(sut.isAuthenticated)
        XCTAssertEqual(mockBiometric.authenticateCallCount, 1)
    }

    func testCheckSession_withBiometricFail_deniesAccess() async {
        mockAuth.checkSessionResult = AuthSession(
            user: AuthUser(id: UUID(), email: "test@test.com"),
            accessToken: "token"
        )
        mockBiometric.canUseBiometricsResult = true
        mockBiometric.biometricEnabled = true
        mockBiometric.authenticateResult = .failure(NSError(domain: "LAError", code: -2))

        await sut.checkSession()

        XCTAssertFalse(sut.isAuthenticated)
    }

    func testCheckSession_withBiometricDisabled_skipsBiometric() async {
        mockAuth.checkSessionResult = AuthSession(
            user: AuthUser(id: UUID(), email: "test@test.com"),
            accessToken: "token"
        )
        mockBiometric.canUseBiometricsResult = true
        mockBiometric.biometricEnabled = false

        await sut.checkSession()

        XCTAssertTrue(sut.isAuthenticated)
        XCTAssertEqual(mockBiometric.authenticateCallCount, 0)
    }

    func testEnableBiometrics_setsPreference() {
        XCTAssertFalse(mockBiometric.isBiometricEnabled)
        sut.enableBiometrics()
        XCTAssertTrue(mockBiometric.isBiometricEnabled)
    }

    // MARK: - Profile Completeness

    func testCheckSession_withCompleteProfile_setsProfileComplete() async {
        let userId = UUID()
        mockAuth.checkSessionResult = AuthSession(
            user: AuthUser(id: userId, email: "test@test.com"),
            accessToken: "token"
        )
        mockProfile.fetchProfileResult = .success(
            UserProfile(
                id: userId,
                name: "Test",
                age: 25,
                bio: "Hello",
                photos: ["a.jpg", "b.jpg"],
                interests: ["Music", "Art", "Food"]
            )
        )

        await sut.checkSession()

        XCTAssertTrue(sut.isAuthenticated)
        XCTAssertTrue(sut.profileComplete)
    }

    func testCheckSession_withIncompleteProfile_setsProfileIncomplete() async {
        let userId = UUID()
        mockAuth.checkSessionResult = AuthSession(
            user: AuthUser(id: userId, email: "test@test.com"),
            accessToken: "token"
        )
        mockProfile.fetchProfileResult = .success(
            UserProfile(id: userId, name: "Test", age: 25, bio: nil, photos: [], interests: [])
        )

        await sut.checkSession()

        XCTAssertTrue(sut.isAuthenticated)
        XCTAssertFalse(sut.profileComplete)
    }

    func testCheckSession_profileFetchFails_defaultsToIncomplete() async {
        let userId = UUID()
        mockAuth.checkSessionResult = AuthSession(
            user: AuthUser(id: userId, email: "test@test.com"),
            accessToken: "token"
        )
        mockProfile.fetchProfileResult = .failure(NSError(domain: "test", code: 404))

        await sut.checkSession()

        XCTAssertTrue(sut.isAuthenticated)
        XCTAssertFalse(sut.profileComplete)
    }

    func testCheckSession_noSession_profileCompleteIsFalse() async {
        mockAuth.checkSessionResult = nil

        await sut.checkSession()

        XCTAssertFalse(sut.isAuthenticated)
        XCTAssertFalse(sut.profileComplete)
    }
}
