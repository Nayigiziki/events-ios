import Foundation

@MainActor
final class RateMatchViewModel: ObservableObject {
    @Published var rating: Int = 0
    @Published var comment: String = ""
    @Published var isSubmitting: Bool = false

    let ratedUser: MockUser

    init(ratedUser: MockUser) {
        self.ratedUser = ratedUser
    }

    func submitRating() async {
        isSubmitting = true
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        isSubmitting = false
    }
}
