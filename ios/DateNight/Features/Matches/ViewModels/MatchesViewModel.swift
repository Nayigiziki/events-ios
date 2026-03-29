import Foundation

@MainActor
class MatchesViewModel: ObservableObject {
    @Published var availableDates: [DateRequest] = []
    @Published var myDates: [DateRequest] = []
    @Published var selectedTab: Int = 0
    @Published var isLoading: Bool = false
    @Published var isJoining: Bool = false
    @Published var errorMessage: String?

    private let dateRequestService: any DateRequestServiceProtocol

    init(dateRequestService: any DateRequestServiceProtocol = SupabaseDateRequestService()) {
        self.dateRequestService = dateRequestService
    }

    func loadDates() async {
        isLoading = true
        errorMessage = nil
        do {
            async let available = dateRequestService.fetchAvailableDates()
            async let mine = dateRequestService.fetchMyDates(status: nil)
            let (availableResult, myResult) = try await (available, mine)
            availableDates = availableResult
            myDates = myResult
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func joinDate(requestId: UUID) async {
        isJoining = true
        errorMessage = nil
        do {
            try await dateRequestService.joinDate(requestId: requestId)
            await loadDates()
        } catch {
            errorMessage = error.localizedDescription
        }
        isJoining = false
    }
}
