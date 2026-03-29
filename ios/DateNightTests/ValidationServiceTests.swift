@testable import DateNight
import XCTest

final class ValidationServiceTests: XCTestCase {
    private var sut: ValidationService!

    override func setUp() {
        super.setUp()
        sut = ValidationService()
    }

    // MARK: - Email Validation

    func testValidEmail_returnsTrue() {
        XCTAssertTrue(sut.isValidEmail("user@example.com"))
        XCTAssertTrue(sut.isValidEmail("test.name@domain.co.uk"))
        XCTAssertTrue(sut.isValidEmail("user+tag@gmail.com"))
    }

    func testInvalidEmail_returnsFalse() {
        XCTAssertFalse(sut.isValidEmail(""))
        XCTAssertFalse(sut.isValidEmail("notanemail"))
        XCTAssertFalse(sut.isValidEmail("@domain.com"))
        XCTAssertFalse(sut.isValidEmail("user@"))
        XCTAssertFalse(sut.isValidEmail("user@.com"))
    }

    // MARK: - Password Strength

    func testStrongPassword_returnsTrue() {
        XCTAssertTrue(sut.isStrongPassword("password1"))
        XCTAssertTrue(sut.isStrongPassword("MySecure9"))
        XCTAssertTrue(sut.isStrongPassword("12345678a"))
    }

    func testWeakPassword_returnsFalse() {
        XCTAssertFalse(sut.isStrongPassword(""))
        XCTAssertFalse(sut.isStrongPassword("short1"))
        XCTAssertFalse(sut.isStrongPassword("abcdefgh"))
        XCTAssertFalse(sut.isStrongPassword("12345678"))
    }

    // MARK: - Non-Empty

    func testNonEmpty_withContent_returnsTrue() {
        XCTAssertTrue(sut.isNonEmpty("hello"))
        XCTAssertTrue(sut.isNonEmpty("a"))
    }

    func testNonEmpty_withEmptyOrWhitespace_returnsFalse() {
        XCTAssertFalse(sut.isNonEmpty(""))
        XCTAssertFalse(sut.isNonEmpty("   "))
        XCTAssertFalse(sut.isNonEmpty("\n"))
    }

    // MARK: - Password Confirmation

    func testPasswordsMatch_whenSame_returnsTrue() {
        XCTAssertTrue(sut.passwordsMatch("password1", "password1"))
    }

    func testPasswordsMatch_whenDifferent_returnsFalse() {
        XCTAssertFalse(sut.passwordsMatch("password1", "password2"))
        XCTAssertFalse(sut.passwordsMatch("password1", "Password1"))
    }
}
