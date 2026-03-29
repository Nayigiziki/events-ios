@testable import DateNight
import XCTest

final class RememberMeTests: XCTestCase {
    private var sut: RememberMeService!
    private let testDefaults = UserDefaults(suiteName: "RememberMeTests")!

    override func setUp() {
        super.setUp()
        testDefaults.removePersistentDomain(forName: "RememberMeTests")
        sut = RememberMeService(defaults: testDefaults)
    }

    func testSaveAndRestore_whenEnabled_persistsEmail() {
        sut.save(email: "user@example.com", enabled: true)
        let result = sut.restore()
        XCTAssertEqual(result.email, "user@example.com")
        XCTAssertTrue(result.enabled)
    }

    func testSaveAndRestore_whenDisabled_clearsEmail() {
        sut.save(email: "user@example.com", enabled: true)
        sut.save(email: "user@example.com", enabled: false)
        let result = sut.restore()
        XCTAssertEqual(result.email, "")
        XCTAssertFalse(result.enabled)
    }

    func testRestore_whenNeverSaved_returnsDefaults() {
        let result = sut.restore()
        XCTAssertEqual(result.email, "")
        XCTAssertFalse(result.enabled)
    }

    func testSave_withEmptyEmail_whenEnabled_stillPersists() {
        sut.save(email: "", enabled: true)
        let result = sut.restore()
        XCTAssertEqual(result.email, "")
        XCTAssertTrue(result.enabled)
    }
}
