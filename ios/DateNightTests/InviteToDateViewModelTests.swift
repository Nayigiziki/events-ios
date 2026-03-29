@testable import DateNight
import XCTest

@MainActor
final class InviteToDateViewModelTests: XCTestCase {
    private var sut: InviteToDateViewModel!
    private var mockService: MockInviteService!
    private let dateRequestId = UUID()

    override func setUp() {
        super.setUp()
        mockService = MockInviteService()
        sut = InviteToDateViewModel(inviteService: mockService, dateRequestId: dateRequestId)
    }

    override func tearDown() {
        sut = nil
        mockService = nil
        super.tearDown()
    }

    // MARK: - Load Data

    func testLoadData_fetchesMatchesAndFriends() async {
        let match = UserProfile(name: "Match User")
        let friend = UserProfile(name: "Friend User")
        mockService.stubbedMatches = [match]
        mockService.stubbedFriends = [friend]

        await sut.loadData()

        XCTAssertTrue(mockService.fetchMatchesCalled)
        XCTAssertTrue(mockService.fetchFriendsCalled)
        XCTAssertEqual(sut.matches.count, 1)
        XCTAssertEqual(sut.friends.count, 1)
        XCTAssertFalse(sut.isLoading)
    }

    func testLoadData_withError_setsErrorMessage() async {
        mockService.stubbedError = NSError(
            domain: "test",
            code: 500,
            userInfo: [NSLocalizedDescriptionKey: "Network error"]
        )

        await sut.loadData()

        XCTAssertEqual(sut.errorMessage, "Network error")
        XCTAssertFalse(sut.isLoading)
    }

    // MARK: - Toggle Invitee

    func testToggleInvitee_addsUser() {
        let user = UserProfile(name: "Alice")
        sut.toggleInvitee(user)

        XCTAssertEqual(sut.selectedInvitees.count, 1)
        XCTAssertEqual(sut.selectedInvitees.first?.id, user.id)
    }

    func testToggleInvitee_removesExistingUser() {
        let user = UserProfile(name: "Alice")
        sut.toggleInvitee(user)
        sut.toggleInvitee(user)

        XCTAssertTrue(sut.selectedInvitees.isEmpty)
    }

    // MARK: - isSelected

    func testIsSelected_returnsTrueForSelectedUser() {
        let user = UserProfile(name: "Alice")
        sut.toggleInvitee(user)

        XCTAssertTrue(sut.isSelected(user))
    }

    func testIsSelected_returnsFalseForUnselectedUser() {
        let user = UserProfile(name: "Alice")
        XCTAssertFalse(sut.isSelected(user))
    }

    // MARK: - Send Invitations

    func testSendInvitations_callsServiceAndClearsSelection() async {
        let user = UserProfile(name: "Alice")
        sut.toggleInvitee(user)

        await sut.sendInvitations()

        XCTAssertEqual(mockService.sendInvitationsCalls.count, 1)
        XCTAssertEqual(mockService.sendInvitationsCalls.first?.dateRequestId, dateRequestId)
        XCTAssertTrue(sut.selectedInvitees.isEmpty)
        XCTAssertTrue(sut.invitationsSent)
        XCTAssertFalse(sut.isSending)
    }

    func testSendInvitations_withNoSelection_doesNotCallService() async {
        await sut.sendInvitations()

        XCTAssertTrue(mockService.sendInvitationsCalls.isEmpty)
        XCTAssertFalse(sut.invitationsSent)
    }

    func testSendInvitations_withError_setsErrorMessage() async {
        let user = UserProfile(name: "Alice")
        sut.toggleInvitee(user)
        mockService.stubbedError = NSError(
            domain: "test",
            code: 500,
            userInfo: [NSLocalizedDescriptionKey: "Send failed"]
        )

        await sut.sendInvitations()

        XCTAssertEqual(sut.errorMessage, "Send failed")
        XCTAssertFalse(sut.isSending)
    }
}
