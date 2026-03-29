@testable import DateNight
import XCTest

@MainActor
final class ForgotPasswordViewModelTests: XCTestCase {
    private var sut: ForgotPasswordViewModel!

    override func setUp() {
        super.setUp()
        sut = ForgotPasswordViewModel()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Defaults

    func testDefaults_allFalseOrEmpty() {
        XCTAssertEqual(sut.email, "")
        XCTAssertFalse(sut.isLoading)
        XCTAssertFalse(sut.isSuccess)
        XCTAssertNil(sut.errorMessage)
    }

    // MARK: - Validation

    func testSendResetLink_emptyEmail_setsError() async {
        sut.email = ""
        await sut.sendResetLink()

        XCTAssertEqual(sut.errorMessage, "Please enter your email address.")
        XCTAssertFalse(sut.isSuccess)
        XCTAssertFalse(sut.isLoading)
    }

    // MARK: - Success

    func testSendResetLink_withEmail_setsIsSuccess() async {
        sut.email = "test@example.com"
        await sut.sendResetLink()

        XCTAssertTrue(sut.isSuccess)
        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
    }

    // MARK: - Loading completes

    func testSendResetLink_isLoadingIsFalseAfterCompletion() async {
        sut.email = "test@example.com"
        await sut.sendResetLink()

        XCTAssertFalse(sut.isLoading)
    }
}
