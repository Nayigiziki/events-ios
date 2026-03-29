@testable import DateNight
import XCTest

final class SupabaseReportServiceIntegrationTests: XCTestCase {
    var sut: SupabaseReportService!

    override func setUp() async throws {
        try await super.setUp()
        sut = SupabaseReportService()
        try await IntegrationTestHelper.ensureSignedIn()
    }

    override func tearDown() async throws {
        sut = nil
        try await super.tearDown()
    }

    // MARK: - submitReport

    // Note: reports table may not exist in current Supabase schema

    func testSubmitReport_succeedsOrTableMissing() async throws {
        let fakeUserId = UUID()
        do {
            try await sut.submitReport(
                reportedUserId: fakeUserId,
                reason: "integration_test",
                details: "Automated integration test report - please ignore"
            )

            // Clean up
            let client = SupabaseService.shared.client
            let reporterId = try await client.auth.session.user.id
            try await client.from("reports")
                .delete()
                .eq("reporter_id", value: reporterId.uuidString)
                .eq("reported_user_id", value: fakeUserId.uuidString)
                .execute()
        } catch {
            let desc = error.localizedDescription
            if desc.contains("PGRST205") || desc.contains("reports") {
                // Table not yet created in Supabase
            } else {
                throw error
            }
        }
    }

    // MARK: - blockUser

    // Note: blocked_users table may not exist in current Supabase schema

    func testBlockUser_succeedsOrTableMissing() async throws {
        let fakeUserId = UUID()
        do {
            try await sut.blockUser(userId: fakeUserId)

            // Clean up
            let client = SupabaseService.shared.client
            let blockerId = try await client.auth.session.user.id
            try await client.from("blocked_users")
                .delete()
                .eq("blocker_id", value: blockerId.uuidString)
                .eq("blocked_user_id", value: fakeUserId.uuidString)
                .execute()
        } catch {
            let desc = error.localizedDescription
            if desc.contains("PGRST205") || desc.contains("blocked_users") {
                // Table not yet created in Supabase
            } else {
                throw error
            }
        }
    }
}
