import Foundation

struct ProfileStats {
    var matches: Int
    var dates: Int
    var events: Int
}

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var profile: MockUser = MockData.currentUser
    @Published var stats = ProfileStats(matches: 12, dates: 8, events: 24)
    @Published var activities: [MockActivity] = MockData.activities
    @Published var selectedPhotoIndex: Int = 0
}
