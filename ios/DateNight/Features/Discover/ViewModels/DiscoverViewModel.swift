import Foundation

// MARK: - DiscoverViewModel

@MainActor
class DiscoverViewModel: ObservableObject {
    @Published var users: [UserProfile] = []
    @Published var currentIndex: Int = 0
    @Published var showFilters: Bool = false
    @Published var showMatchDetail: Bool = false
    @Published var matchedUser: UserProfile?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var filters = DiscoverFilters()

    private let discoverService: any DiscoverServiceProtocol

    var currentUser: UserProfile? {
        guard currentIndex < users.count else { return nil }
        return users[currentIndex]
    }

    var nextUser: UserProfile? {
        guard currentIndex + 1 < users.count else { return nil }
        return users[currentIndex + 1]
    }

    var remainingCount: Int {
        max(0, users.count - currentIndex)
    }

    init(discoverService: any DiscoverServiceProtocol = SupabaseDiscoverService()) {
        self.discoverService = discoverService
    }

    func loadUsers() async {
        isLoading = true
        errorMessage = nil
        do {
            users = try await discoverService.fetchNearbyUsers(filters: filters)
            currentIndex = 0
        } catch {
            errorMessage = error.localizedDescription
            users = []
        }
        isLoading = false
    }

    func swipeRight(userId: UUID) async {
        let liked = currentUser
        do {
            let result = try await discoverService.recordSwipe(userId: userId, direction: .right)
            advanceIndex()
            if case .matched = result, let liked {
                matchedUser = liked
                showMatchDetail = true
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func swipeLeft(userId: UUID) async {
        do {
            try await discoverService.recordSwipe(userId: userId, direction: .left)
            advanceIndex()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func dismissMatch() {
        showMatchDetail = false
        matchedUser = nil
    }

    private func advanceIndex() {
        if currentIndex < users.count {
            currentIndex += 1
        }
    }
}
