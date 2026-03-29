@testable import DateNight
import XCTest

@MainActor
final class EventDetailViewModelTests: XCTestCase {
    private var sut: EventDetailViewModel!
    private var mockService: MockEventService!
    private var mockFriendService: MockFriendService!
    private var testEvent: Event!

    override func setUp() {
        super.setUp()
        mockService = MockEventService()
        mockFriendService = MockFriendService()
        testEvent = Event(
            title: "Test Event",
            category: "Music",
            date: "March 28, 2026",
            time: "8:00 PM",
            venue: "Test Venue",
            location: "Test Location",
            price: "$25",
            description: "A test event",
            totalSpots: 100
        )
        sut = EventDetailViewModel(event: testEvent, eventService: mockService, friendService: mockFriendService)
    }

    override func tearDown() {
        sut = nil
        mockService = nil
        mockFriendService = nil
        testEvent = nil
        super.tearDown()
    }

    // MARK: - Load Comments

    func testLoadComments_fetchesFromService() async {
        let comment = EventComment(userName: "Alice", text: "Great!", timestamp: "1h ago")
        mockService.stubbedComments = [comment]

        await sut.loadComments()

        XCTAssertEqual(sut.comments.count, 1)
        XCTAssertEqual(sut.comments.first?.userName, "Alice")
    }

    func testLoadComments_withError_setsErrorMessage() async {
        mockService.stubbedError = NSError(
            domain: "test",
            code: 500,
            userInfo: [NSLocalizedDescriptionKey: "Server error"]
        )

        await sut.loadComments()

        XCTAssertNotNil(sut.errorMessage)
    }

    // MARK: - Add Comment

    func testAddComment_callsServiceWithCorrectEventId() async {
        sut.newCommentText = "New comment"

        await sut.addComment()

        XCTAssertEqual(mockService.addCommentCalls.count, 1)
        XCTAssertEqual(mockService.addCommentCalls.first?.eventId, testEvent.id)
        XCTAssertEqual(mockService.addCommentCalls.first?.text, "New comment")
    }

    func testAddComment_insertsCommentAtTop() async {
        let existing = EventComment(userName: "Old", text: "Old comment", timestamp: "2h ago")
        sut.comments = [existing]
        sut.newCommentText = "New comment"

        await sut.addComment()

        XCTAssertEqual(sut.comments.count, 2)
        XCTAssertEqual(sut.comments.first?.text, "New comment")
    }

    func testAddComment_clearsTextField() async {
        sut.newCommentText = "Some text"

        await sut.addComment()

        XCTAssertTrue(sut.newCommentText.isEmpty)
    }

    func testAddComment_emptyText_doesNotCallService() async {
        sut.newCommentText = "   "

        await sut.addComment()

        XCTAssertTrue(mockService.addCommentCalls.isEmpty)
    }

    // MARK: - Vote

    func testVote_callsServiceWithCorrectParams() async {
        let comment = EventComment(userName: "Test", text: "Comment", timestamp: "1h ago")
        sut.comments = [comment]

        await sut.vote(commentId: comment.id, direction: .up)

        XCTAssertEqual(mockService.voteCommentCalls.count, 1)
        XCTAssertEqual(mockService.voteCommentCalls.first?.commentId, comment.id)
        XCTAssertEqual(mockService.voteCommentCalls.first?.direction, .up)
    }

    func testVote_upvote_incrementsCount() async {
        let comment = EventComment(userName: "Test", text: "Comment", timestamp: "1h ago", upvotes: 0)
        sut.comments = [comment]

        await sut.vote(commentId: comment.id, direction: .up)

        XCTAssertEqual(sut.comments.first?.upvotes, 1)
        XCTAssertEqual(sut.comments.first?.userVote, .up)
    }

    func testVote_toggleSameDirection_removesVote() async {
        let comment = EventComment(userName: "Test", text: "Comment", timestamp: "1h ago", upvotes: 1, userVote: .up)
        sut.comments = [comment]

        await sut.vote(commentId: comment.id, direction: .up)

        XCTAssertEqual(sut.comments.first?.upvotes, 0)
        XCTAssertNil(sut.comments.first?.userVote)
    }

    // MARK: - Create Date

    func testCreateDate_callsServiceWithCorrectFields() async {
        sut.dateType = .group
        sut.groupSize = 4
        sut.dateDescription = "Let's go!"

        await sut.createDate()

        XCTAssertEqual(mockService.createDateCalls.count, 1)
        let request = mockService.createDateCalls.first
        XCTAssertEqual(request?.eventId, testEvent.id)
        XCTAssertEqual(request?.dateType, "Group")
        XCTAssertEqual(request?.groupSize, 4)
        XCTAssertEqual(request?.description, "Let's go!")
    }

    func testCreateDate_resetsFormOnSuccess() async {
        sut.dateType = .group
        sut.groupSize = 4
        sut.dateDescription = "Let's go!"
        sut.invitedUserIds = [UUID()]

        await sut.createDate()

        XCTAssertFalse(sut.showCreateDate)
        XCTAssertTrue(sut.dateDescription.isEmpty)
        XCTAssertEqual(sut.dateType, .solo)
        XCTAssertEqual(sut.groupSize, 2)
        XCTAssertTrue(sut.invitedUserIds.isEmpty)
    }

    func testCreateDate_passesInvitedUserIds() async {
        let userId1 = UUID()
        let userId2 = UUID()
        sut.invitedUserIds = [userId1, userId2]

        await sut.createDate()

        let request = mockService.createDateCalls.first
        XCTAssertEqual(Set(request?.invitedUserIds ?? []), [userId1, userId2])
    }

    func testCreateDate_withError_setsErrorMessage() async {
        mockService.stubbedError = NSError(domain: "test", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed"])

        await sut.createDate()

        XCTAssertNotNil(sut.errorMessage)
    }

    // MARK: - RSVP

    func testRsvp_callsServiceAndUpdatesState() async {
        await sut.rsvp()

        XCTAssertEqual(mockService.rsvpEventCalls.count, 1)
        XCTAssertTrue(sut.isAttending)
    }

    func testUnrsvp_callsServiceAndUpdatesState() async {
        sut.isAttending = true

        await sut.unrsvp()

        XCTAssertEqual(mockService.unrsvpEventCalls.count, 1)
        XCTAssertFalse(sut.isAttending)
    }

    func testRsvp_withError_doesNotSetAttending() async {
        mockService.stubbedError = NSError(domain: "test", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed"])

        await sut.rsvp()

        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.isAttending)
    }

    // MARK: - Share

    func testShareText_containsEventDetails() {
        let text = sut.shareText

        XCTAssertTrue(text.contains("Test Event"))
        XCTAssertTrue(text.contains("Test Venue"))
        XCTAssertTrue(text.contains("March 28, 2026"))
    }

    // MARK: - Invite Users

    func testLoadInvitableUsers_populatesFriends() async {
        let friends = [
            UserProfile(id: UUID(), name: "Emma"),
            UserProfile(id: UUID(), name: "Alex")
        ]
        mockFriendService.fetchFriendsResult = .success(friends)

        await sut.loadInvitableUsers()

        XCTAssertEqual(sut.invitableUsers.count, 2)
        XCTAssertEqual(mockFriendService.fetchFriendsCallCount, 1)
    }

    func testLoadInvitableUsers_failure_keepsEmptyList() async {
        mockFriendService.fetchFriendsResult = .failure(NSError(domain: "test", code: 1))

        await sut.loadInvitableUsers()

        XCTAssertTrue(sut.invitableUsers.isEmpty)
    }

    func testToggleInvite_addsUserId() {
        let userId = UUID()

        sut.toggleInvite(userId)

        XCTAssertTrue(sut.invitedUserIds.contains(userId))
    }

    func testToggleInvite_removesExistingUserId() {
        let userId = UUID()
        sut.invitedUserIds = [userId]

        sut.toggleInvite(userId)

        XCTAssertFalse(sut.invitedUserIds.contains(userId))
    }

    func testInitialState_invitedUsersEmpty() {
        XCTAssertTrue(sut.invitableUsers.isEmpty)
        XCTAssertTrue(sut.invitedUserIds.isEmpty)
    }
}
