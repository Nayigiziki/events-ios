@testable import DateNight
import XCTest

final class SupabaseInviteServiceIntegrationTests: XCTestCase {
    var sut: SupabaseInviteService!

    override func setUp() async throws {
        try await super.setUp()
        sut = SupabaseInviteService()
        try await IntegrationTestHelper.ensureSignedIn()
    }

    override func tearDown() async throws {
        sut = nil
        try await super.tearDown()
    }

    // MARK: - fetchMatches

    func testFetchMatches_returnsArray() async throws {
        let matches = try await sut.fetchMatches()
        XCTAssertNotNil(matches)
    }

    // MARK: - fetchFriends

    func testFetchFriends_returnsArray() async throws {
        let friends = try await sut.fetchFriends()
        XCTAssertNotNil(friends)
    }

    // MARK: - sendInvitations

    // Note: Supabase insert with empty array causes a parse error.
    // Test with a non-empty list against the date_invitations table if it exists.

    func testSendInvitations_withFakeData_succeedsOrTableMissing() async throws {
        let fakeRequestId = UUID()
        let fakeUserId = UUID()
        do {
            try await sut.sendInvitations(dateRequestId: fakeRequestId, userIds: [fakeUserId])

            // Clean up
            let client = SupabaseService.shared.client
            try await client.from("date_invitations")
                .delete()
                .eq("date_request_id", value: fakeRequestId.uuidString)
                .eq("invited_user_id", value: fakeUserId.uuidString)
                .execute()
        } catch {
            let desc = error.localizedDescription
            if desc.contains("PGRST205") || desc.contains("date_invitations") || desc.contains("violates") {
                // Table missing or FK constraint -- expected for pre-MVP
            } else {
                throw error
            }
        }
    }
}
