import Foundation

protocol ReportServiceProtocol: Sendable {
    func submitReport(reportedUserId: UUID, reason: String, details: String) async throws
    func blockUser(userId: UUID) async throws
}
