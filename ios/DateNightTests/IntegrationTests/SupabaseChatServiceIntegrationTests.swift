@testable import DateNight
import XCTest

final class SupabaseChatServiceIntegrationTests: XCTestCase {
    var sut: SupabaseChatService!

    override func setUp() async throws {
        try await super.setUp()
        sut = SupabaseChatService()
        try await IntegrationTestHelper.ensureSignedIn()
    }

    override func tearDown() async throws {
        sut = nil
        try await super.tearDown()
    }

    // MARK: - fetchConversations (stub - returns empty)

    func testFetchConversations_returnsEmptyArray() async throws {
        let conversations = try await sut.fetchConversations()
        XCTAssertTrue(conversations.isEmpty)
    }

    // MARK: - fetchMessages (stub - returns empty)

    func testFetchMessages_returnsEmptyArray() async throws {
        let messages = try await sut.fetchMessages(conversationId: UUID())
        XCTAssertTrue(messages.isEmpty)
    }

    // MARK: - sendMessage (stub - throws error)

    func testSendMessage_throwsNotImplemented() async {
        do {
            _ = try await sut.sendMessage(conversationId: UUID(), content: "Test", messageType: .text)
            XCTFail("Expected sendMessage to throw (not yet implemented)")
        } catch {
            XCTAssertTrue(error.localizedDescription.contains("not yet implemented"))
        }
    }

    // MARK: - currentUserId

    func testCurrentUserId_returnsAuthenticatedUserId() async throws {
        let userId = try await sut.currentUserId()
        let expectedId = try await IntegrationTestHelper.currentUserId()
        XCTAssertEqual(userId, expectedId)
    }
}
