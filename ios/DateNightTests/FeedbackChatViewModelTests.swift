@testable import DateNight
import XCTest

@MainActor
final class FeedbackChatViewModelTests: XCTestCase {
    private var sut: FeedbackChatViewModel!

    override func setUp() {
        super.setUp()
        sut = FeedbackChatViewModel()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Init

    func testInit_hasWelcomeMessage() {
        XCTAssertEqual(sut.messages.count, 1)
        XCTAssertFalse(sut.messages.first!.isUser)
        XCTAssertTrue(sut.messages.first!.text.contains("Hola"))
    }

    // MARK: - canSend

    func testCanSend_falseWhenInputEmpty() {
        sut.inputText = ""
        XCTAssertFalse(sut.canSend)
    }

    func testCanSend_falseWhenInputIsWhitespace() {
        sut.inputText = "   "
        XCTAssertFalse(sut.canSend)
    }

    func testCanSend_trueWhenInputHasText() {
        sut.inputText = "Great app!"
        XCTAssertTrue(sut.canSend)
    }

    // MARK: - sendMessage

    func testSendMessage_emptyInput_doesNotAppendMessage() async {
        sut.inputText = ""
        await sut.sendMessage()

        // Only the initial welcome message
        XCTAssertEqual(sut.messages.count, 1)
    }

    func testSendMessage_appendsUserMessage() async {
        sut.inputText = "I love the events feature"
        await sut.sendMessage()

        // Welcome + user message + bot fallback response (no API key)
        XCTAssertGreaterThanOrEqual(sut.messages.count, 2)
        XCTAssertTrue(sut.messages[1].isUser)
        XCTAssertEqual(sut.messages[1].text, "I love the events feature")
    }

    func testSendMessage_clearsInputText() async {
        sut.inputText = "Some feedback"
        await sut.sendMessage()

        XCTAssertEqual(sut.inputText, "")
    }

    func testSendMessage_isStreamingIsFalseAfterCompletion() async {
        sut.inputText = "Test"
        await sut.sendMessage()

        XCTAssertFalse(sut.isStreaming)
    }
}
