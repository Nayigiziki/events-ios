import Foundation

@MainActor
class MatchesViewModel: ObservableObject {
    @Published var availableDates: [DateRequest] = DiscoverMockData.dateRequests
    @Published var myDates: [DateRequest] = []
    @Published var selectedTab: Int = 0

    init() {
        self.myDates = DiscoverMockData.dateRequests.filter { $0.status == .confirmed }
    }

    func joinDate(requestId: UUID) {
        if let index = availableDates.firstIndex(where: { $0.id == requestId }) {
            print("Joined date: \(availableDates[index].event?.title ?? "unknown")")
        }
    }
}
