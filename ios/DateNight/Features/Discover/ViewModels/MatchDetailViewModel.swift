import Foundation

@MainActor
class MatchDetailViewModel: ObservableObject {
    @Published var matchedUser: UserProfile
    @Published var sharedInterests: [String]

    init(matchedUser: UserProfile, currentUserInterests: [String] = ["Music", "Art", "Food", "Comedy"]) {
        self.matchedUser = matchedUser
        self.sharedInterests = matchedUser.interests.filter { currentUserInterests.contains($0) }
    }
}
