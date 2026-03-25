import Foundation

@MainActor
final class ReportUserViewModel: ObservableObject {
    @Published var selectedReason: String = ""
    @Published var additionalDetails: String = ""
    @Published var isSubmitting: Bool = false

    let reportedUser: MockUser

    let reasons = [
        "Inappropriate behavior",
        "Fake profile",
        "Spam",
        "Harassment",
        "Other"
    ]

    init(reportedUser: MockUser) {
        self.reportedUser = reportedUser
    }

    func submitReport() async {
        isSubmitting = true
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        isSubmitting = false
    }

    func blockUser() async {
        try? await Task.sleep(nanoseconds: 500_000_000)
    }
}
