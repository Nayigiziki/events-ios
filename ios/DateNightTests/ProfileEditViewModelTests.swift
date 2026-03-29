@testable import DateNight
import XCTest

@MainActor
final class ProfileEditViewModelTests: XCTestCase {
    private var sut: ProfileEditViewModel!

    override func setUp() {
        super.setUp()
        sut = ProfileEditViewModel()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Init

    func testInit_setsEmptyDefaults() {
        XCTAssertEqual(sut.name, "")
        XCTAssertEqual(sut.bio, "")
        XCTAssertEqual(sut.photos, [])
        XCTAssertEqual(sut.interests, [])
    }

    func testInit_setsDefaults() {
        XCTAssertEqual(sut.occupation, "")
        XCTAssertEqual(sut.height, "")
        XCTAssertFalse(sut.isReadyToMingle)
        XCTAssertEqual(sut.newInterest, "")
    }

    // MARK: - Remove Photo

    func testRemovePhoto_removesAtValidIndex() {
        let initialCount = sut.photos.count
        guard initialCount > 0 else { return }

        sut.removePhoto(at: 0)
        XCTAssertEqual(sut.photos.count, initialCount - 1)
    }

    func testRemovePhoto_outOfBounds_doesNotCrash() {
        let initialCount = sut.photos.count
        sut.removePhoto(at: 999)
        XCTAssertEqual(sut.photos.count, initialCount)
    }

    // MARK: - Add Interest

    func testAddInterest_appendsNewInterest() {
        sut.newInterest = "Photography"
        sut.addInterest()

        XCTAssertTrue(sut.interests.contains("Photography"))
        XCTAssertEqual(sut.newInterest, "")
    }

    func testAddInterest_emptyString_doesNotAdd() {
        let before = sut.interests.count
        sut.newInterest = "   "
        sut.addInterest()

        XCTAssertEqual(sut.interests.count, before)
    }

    func testAddInterest_duplicate_doesNotAdd() {
        sut.newInterest = "UniqueTest"
        sut.addInterest()
        let countAfterFirst = sut.interests.count

        sut.newInterest = "UniqueTest"
        sut.addInterest()

        XCTAssertEqual(sut.interests.count, countAfterFirst)
    }

    func testAddInterest_trimsWhitespace() {
        sut.newInterest = "  Hiking  "
        sut.addInterest()

        XCTAssertTrue(sut.interests.contains("Hiking"))
        XCTAssertFalse(sut.interests.contains("  Hiking  "))
    }

    // MARK: - Remove Interest

    func testRemoveInterest_removesExisting() {
        sut.newInterest = "ToRemove"
        sut.addInterest()
        XCTAssertTrue(sut.interests.contains("ToRemove"))

        sut.removeInterest("ToRemove")
        XCTAssertFalse(sut.interests.contains("ToRemove"))
    }

    func testRemoveInterest_nonExistent_doesNotCrash() {
        let before = sut.interests.count
        sut.removeInterest("NonExistent999")
        XCTAssertEqual(sut.interests.count, before)
    }

    // MARK: - Availability

    func testAvailabilityToggle_changesReadyToMingle() {
        sut.isReadyToMingle = false
        XCTAssertFalse(sut.isReadyToMingle)

        sut.isReadyToMingle = true
        XCTAssertTrue(sut.isReadyToMingle)
    }
}
