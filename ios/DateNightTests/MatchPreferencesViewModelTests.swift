@testable import DateNight
import XCTest

@MainActor
final class MatchPreferencesViewModelTests: XCTestCase {
    private var sut: MatchPreferencesViewModel!

    override func setUp() {
        super.setUp()
        sut = MatchPreferencesViewModel()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Defaults

    func testDefaults_ageRange() {
        XCTAssertEqual(sut.ageMin, 18)
        XCTAssertEqual(sut.ageMax, 35)
    }

    func testDefaults_distance() {
        XCTAssertEqual(sut.distance, 25)
    }

    func testDefaults_emptySelections() {
        XCTAssertTrue(sut.selectedTypes.isEmpty)
        XCTAssertTrue(sut.selectedInterests.isEmpty)
    }

    // MARK: - Toggle Type

    func testToggleType_addsType() {
        sut.toggleType("Casual")
        XCTAssertTrue(sut.selectedTypes.contains("Casual"))
    }

    func testToggleType_removesExistingType() {
        sut.toggleType("Casual")
        sut.toggleType("Casual")
        XCTAssertFalse(sut.selectedTypes.contains("Casual"))
    }

    // MARK: - Toggle Interest

    func testToggleInterest_addsInterest() {
        sut.toggleInterest("Music")
        XCTAssertTrue(sut.selectedInterests.contains("Music"))
    }

    func testToggleInterest_removesExistingInterest() {
        sut.toggleInterest("Music")
        sut.toggleInterest("Music")
        XCTAssertFalse(sut.selectedInterests.contains("Music"))
    }

    // MARK: - Age / Distance Ranges

    func testAgeRange_canBeUpdated() {
        sut.ageMin = 21
        sut.ageMax = 40
        XCTAssertEqual(sut.ageMin, 21)
        XCTAssertEqual(sut.ageMax, 40)
    }

    func testDistance_canBeUpdated() {
        sut.distance = 50
        XCTAssertEqual(sut.distance, 50)
    }

    // MARK: - Save

    func testSave_setsIsSavingDuringSave() async {
        XCTAssertFalse(sut.isSaving)
        await sut.save()
        XCTAssertFalse(sut.isSaving)
    }
}
