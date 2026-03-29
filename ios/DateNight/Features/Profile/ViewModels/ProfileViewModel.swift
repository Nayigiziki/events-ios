import Foundation

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var profile: UserProfile?
    @Published var stats = ProfileStats()
    @Published var activities: [Activity] = []
    @Published var selectedPhotoIndex: Int = 0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let profileService: ProfileServiceProtocol
    private let userId: UUID

    init(profileService: ProfileServiceProtocol, userId: UUID) {
        self.profileService = profileService
        self.userId = userId
    }

    func loadProfile() async {
        isLoading = true
        errorMessage = nil

        do {
            async let profileTask = profileService.fetchProfile(userId: userId)
            async let statsTask = profileService.fetchStats(userId: userId)
            async let activityTask = profileService.fetchActivity(userId: userId)

            let (fetchedProfile, fetchedStats, fetchedActivity) = try await (profileTask, statsTask, activityTask)

            profile = fetchedProfile
            stats = fetchedStats
            activities = fetchedActivity
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
