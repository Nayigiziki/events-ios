import Foundation

@MainActor
class DateDetailViewModel: ObservableObject {
    @Published var dateRequest: DateRequest
    @Published var showChat = false
    @Published var showCancelConfirmation = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let dateRequestService: any DateRequestServiceProtocol

    init(dateRequest: DateRequest, dateRequestService: any DateRequestServiceProtocol = SupabaseDateRequestService()) {
        self.dateRequest = dateRequest
        self.dateRequestService = dateRequestService
    }

    func confirm() async {
        isLoading = true
        errorMessage = nil
        do {
            try await dateRequestService.confirmDate(requestId: dateRequest.id)
            dateRequest.status = .confirmed
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func requestCancel() {
        showCancelConfirmation = true
    }

    func confirmCancel() async {
        isLoading = true
        errorMessage = nil
        do {
            try await dateRequestService.cancelDate(requestId: dateRequest.id)
            dateRequest.status = .cancelled
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func openChat() {
        showChat = true
    }

    // MARK: - Display Helpers

    var statusDisplay: String {
        switch dateRequest.status {
        case .open: "status_open".localized()
        case .full: "status_full".localized()
        case .confirmed: "status_confirmed".localized()
        case .cancelled: "status_cancelled".localized()
        }
    }

    var isCompleted: Bool {
        false
    }
}
