@testable import DateNight
import XCTest

@MainActor
final class ProfileSetupViewModelTests: XCTestCase {
    private var mockService: MockProfileService!
    private var sut: ProfileSetupViewModel!
    private let testUserId = UUID()

    override func setUp() {
        super.setUp()
        mockService = MockProfileService()
        sut = ProfileSetupViewModel(profileService: mockService, userId: testUserId)
    }

    // MARK: - Step Navigation

    func testInitialStep_isZero() {
        XCTAssertEqual(sut.currentStep, 0)
    }

    func testNextStep_incrementsStep() {
        sut.currentStep = 0
        sut.nextStep()
        XCTAssertEqual(sut.currentStep, 1)
    }

    func testNextStep_doesNotExceedMax() {
        sut.currentStep = ProfileSetupViewModel.totalSteps - 1
        sut.nextStep()
        XCTAssertEqual(sut.currentStep, ProfileSetupViewModel.totalSteps - 1)
    }

    func testPreviousStep_decrementsStep() {
        sut.currentStep = 1
        sut.previousStep()
        XCTAssertEqual(sut.currentStep, 0)
    }

    func testPreviousStep_doesNotGoBelowZero() {
        sut.currentStep = 0
        sut.previousStep()
        XCTAssertEqual(sut.currentStep, 0)
    }

    // MARK: - Can Proceed

    func testCanProceed_step0_needsMinPhotos() {
        sut.currentStep = 0
        sut.photos = ["photo1.jpg"]
        XCTAssertFalse(sut.canProceed)

        sut.photos = ["photo1.jpg", "photo2.jpg"]
        XCTAssertTrue(sut.canProceed)
    }

    func testCanProceed_step1_needsBio() {
        sut.currentStep = 1
        sut.bio = ""
        XCTAssertFalse(sut.canProceed)

        sut.bio = "Hello world"
        XCTAssertTrue(sut.canProceed)
    }

    func testCanProceed_step2_needsMinInterests() {
        sut.currentStep = 2
        sut.selectedInterests = Set(["Music", "Art"])
        XCTAssertFalse(sut.canProceed)

        sut.selectedInterests = Set(["Music", "Art", "Food"])
        XCTAssertTrue(sut.canProceed)
    }

    // MARK: - Toggle Interest

    func testToggleInterest_addsAndRemoves() {
        sut.toggleInterest("Music")
        XCTAssertTrue(sut.selectedInterests.contains("Music"))

        sut.toggleInterest("Music")
        XCTAssertFalse(sut.selectedInterests.contains("Music"))
    }

    // MARK: - Photo Management

    func testRemovePhoto_removesAtIndex() {
        sut.photos = ["a.jpg", "b.jpg", "c.jpg"]
        sut.removePhoto(at: 1)
        XCTAssertEqual(sut.photos, ["a.jpg", "c.jpg"])
    }

    func testRemovePhoto_invalidIndex_doesNothing() {
        sut.photos = ["a.jpg"]
        sut.removePhoto(at: 5)
        XCTAssertEqual(sut.photos, ["a.jpg"])
    }

    // MARK: - Complete Setup

    func testCompleteSetup_callsUpdateProfile() async {
        sut.photos = ["photo1.jpg", "photo2.jpg"]
        sut.bio = "Test bio"
        sut.occupation = "Engineer"
        sut.location = "Austin, TX"
        sut.height = "72"
        sut.selectedInterests = Set(["Music", "Art", "Food"])

        await sut.completeSetup()

        XCTAssertEqual(mockService.updateProfileCallCount, 1)
        XCTAssertNotNil(mockService.lastUpdateRequest)
        XCTAssertEqual(mockService.lastUpdateRequest?.bio, "Test bio")
        XCTAssertEqual(mockService.lastUpdateRequest?.occupation, "Engineer")
        XCTAssertEqual(mockService.lastUpdateRequest?.height, 72)
        XCTAssertEqual(mockService.lastUpdateRequest?.photos, ["photo1.jpg", "photo2.jpg"])
        XCTAssertEqual(Set(mockService.lastUpdateRequest?.interests ?? []), Set(["Music", "Art", "Food"]))
    }

    func testCompleteSetup_setsIsComplete() async {
        sut.photos = ["photo1.jpg", "photo2.jpg"]
        sut.bio = "Bio"
        sut.selectedInterests = Set(["A", "B", "C"])

        await sut.completeSetup()

        XCTAssertTrue(sut.isComplete)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }

    func testCompleteSetup_onError_setsErrorMessage() async {
        mockService.updateProfileError = NSError(
            domain: "test",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "Network error"]
        )
        sut.photos = ["photo1.jpg", "photo2.jpg"]
        sut.bio = "Bio"
        sut.selectedInterests = Set(["A", "B", "C"])

        await sut.completeSetup()

        XCTAssertFalse(sut.isComplete)
        XCTAssertFalse(sut.isLoading)
        XCTAssertEqual(sut.errorMessage, "Network error")
    }

    func testCompleteSetup_setsLoadingDuringExecution() async {
        sut.photos = ["photo1.jpg", "photo2.jpg"]
        sut.bio = "Bio"
        sut.selectedInterests = Set(["A", "B", "C"])

        XCTAssertFalse(sut.isLoading)
        await sut.completeSetup()
        XCTAssertFalse(sut.isLoading)
    }

    func testCompleteSetup_heightParsing_invalidString_sendsNil() async {
        sut.photos = ["photo1.jpg", "photo2.jpg"]
        sut.bio = "Bio"
        sut.height = "not a number"
        sut.selectedInterests = Set(["A", "B", "C"])

        await sut.completeSetup()

        XCTAssertNil(mockService.lastUpdateRequest?.height)
    }

    // MARK: - Photo Upload

    func testAddPhotoData_uploadsAndAppendsURL() async {
        let testData = Data("fake-image".utf8)

        await sut.addPhotoData(testData)

        XCTAssertEqual(mockService.uploadPhotoCallCount, 1)
        XCTAssertEqual(sut.photos.count, 1)
        XCTAssertEqual(sut.photos.first, "https://example.com/photo.jpg")
    }

    func testAddPhotoData_atMaxPhotos_doesNotUpload() async {
        sut.photos = (0 ..< ProfileSetupViewModel.maxPhotos).map { "photo\($0).jpg" }
        let testData = Data("fake-image".utf8)

        await sut.addPhotoData(testData)

        XCTAssertEqual(mockService.uploadPhotoCallCount, 0)
        XCTAssertEqual(sut.photos.count, ProfileSetupViewModel.maxPhotos)
    }

    func testAddPhotoData_onError_setsErrorMessage() async {
        mockService.uploadPhotoResult = .failure(NSError(
            domain: "test",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "Upload failed"]
        ))
        let testData = Data("fake-image".utf8)

        await sut.addPhotoData(testData)

        XCTAssertEqual(sut.photos.count, 0)
        XCTAssertEqual(sut.errorMessage, "Upload failed")
        XCTAssertFalse(sut.isUploadingPhoto)
    }

    func testAddPhotoData_setsIsUploadingPhoto() async {
        let testData = Data("fake-image".utf8)

        XCTAssertFalse(sut.isUploadingPhoto)
        await sut.addPhotoData(testData)
        XCTAssertFalse(sut.isUploadingPhoto)
    }

    func testCompleteSetup_noUserId_setsError() async {
        let noUserSut = ProfileSetupViewModel(profileService: mockService, userId: nil)
        noUserSut.photos = ["a.jpg", "b.jpg"]
        noUserSut.bio = "Bio"
        noUserSut.selectedInterests = Set(["A", "B", "C"])

        await noUserSut.completeSetup()

        XCTAssertEqual(noUserSut.errorMessage, "No user session found")
        XCTAssertFalse(noUserSut.isComplete)
    }
}
