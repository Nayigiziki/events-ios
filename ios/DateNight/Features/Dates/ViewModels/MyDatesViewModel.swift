import Foundation

@MainActor
class MyDatesViewModel: ObservableObject {
    @Published var selectedTab = 0
    @Published var upcoming: [DateRequest] = []
    @Published var past: [DateRequest] = []
    @Published var cancelled: [DateRequest] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let dateRequestService: any DateRequestServiceProtocol

    init(dateRequestService: any DateRequestServiceProtocol = SupabaseDateRequestService()) {
        self.dateRequestService = dateRequestService
    }

    func loadDates() async {
        isLoading = true
        errorMessage = nil
        do {
            let allDates = try await dateRequestService.fetchMyDates(status: nil)
            upcoming = allDates.filter { $0.status == .open || $0.status == .confirmed || $0.status == .full }
            past = allDates.filter { $0.status == .confirmed }
            cancelled = allDates.filter { $0.status == .cancelled }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
