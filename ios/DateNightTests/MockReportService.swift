@testable import DateNight
import Foundation

final class MockReportService: ReportServiceProtocol, @unchecked Sendable {
    var submitReportCallCount = 0
    var blockUserCallCount = 0
    var lastReportedUserId: UUID?
    var lastBlockedUserId: UUID?
    var lastReason: String?
    var lastDetails: String?
    var shouldFail = false

    func submitReport(reportedUserId: UUID, reason: String, details: String) async throws {
        submitReportCallCount += 1
        lastReportedUserId = reportedUserId
        lastReason = reason
        lastDetails = details
        if shouldFail {
            throw NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Report failed"])
        }
    }

    func blockUser(userId: UUID) async throws {
        blockUserCallCount += 1
        lastBlockedUserId = userId
        if shouldFail {
            throw NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Block failed"])
        }
    }
}
