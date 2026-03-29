import Foundation

@MainActor
final class ReportUserViewModel: ObservableObject {
    @Published var selectedReason: String = ""
    @Published var additionalDetails: String = ""
    @Published var isSubmitting: Bool = false
    @Published var reportSubmitted: Bool = false
    @Published var errorMessage: String?

    let reportedUser: UserProfile

    let reasons = [
        "Inappropriate behavior",
        "Fake profile",
        "Spam",
        "Harassment",
        "Other"
    ]

    private let reportService: any ReportServiceProtocol

    init(reportedUser: UserProfile, reportService: any ReportServiceProtocol = SupabaseReportService()) {
        self.reportedUser = reportedUser
        self.reportService = reportService
    }

    func submitReport() async {
        isSubmitting = true
        errorMessage = nil
        do {
            try await reportService.submitReport(
                reportedUserId: reportedUser.id,
                reason: selectedReason,
                details: additionalDetails
            )
            reportSubmitted = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isSubmitting = false
    }

    func blockUser() async {
        errorMessage = nil
        do {
            try await reportService.blockUser(userId: reportedUser.id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
