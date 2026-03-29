@testable import DateNight
import XCTest

@MainActor
final class SettingsViewModelTests: XCTestCase {
    private var sut: SettingsViewModel!

    override func setUp() {
        super.setUp()
        sut = SettingsViewModel()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Notification Toggles

    func testNotifyMatches_defaultsToTrue() {
        XCTAssertTrue(sut.notifyMatches)
    }

    func testToggleNotifyMatches_persistsValue() {
        sut.notifyMatches = false
        XCTAssertFalse(sut.notifyMatches)
    }

    func testToggleNotifyMessages_persistsValue() {
        sut.notifyMessages = false
        XCTAssertFalse(sut.notifyMessages)
    }

    // MARK: - Privacy Toggles

    func testShowOnlineStatus_defaultsToFalse() {
        XCTAssertFalse(sut.showOnlineStatus)
    }

    func testToggleShowProfile_persistsValue() {
        XCTAssertTrue(sut.showProfile)
        sut.showProfile = false
        XCTAssertFalse(sut.showProfile)
    }

    // MARK: - Language

    func testSelectedLanguage_defaultsToEnglish() {
        XCTAssertEqual(sut.selectedLanguage, "English")
    }

    func testSelectLanguage_changesValue() {
        sut.selectedLanguage = "Spanish"
        XCTAssertEqual(sut.selectedLanguage, "Spanish")
    }

    func testLanguages_containsExpectedOptions() {
        XCTAssertEqual(sut.languages, ["English", "Spanish"])
    }

    // MARK: - Dark Mode

    func testDarkMode_defaultsToFalse() {
        XCTAssertFalse(sut.darkModeEnabled)
    }

    func testToggleDarkMode_persistsValue() {
        sut.darkModeEnabled = true
        XCTAssertTrue(sut.darkModeEnabled)
    }
}
