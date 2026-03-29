import Foundation

@MainActor
final class RateMatchViewModel: ObservableObject {
    @Published var rating: Int = 0
    @Published var comment: String = ""
    @Published var isSubmitting: Bool = false
    @Published var didSubmit: Bool = false
    @Published var errorMessage: String?

    let ratedUser: UserProfile
    private let ratingService: any RatingServiceProtocol

    init(ratedUser: UserProfile, ratingService: any RatingServiceProtocol = SupabaseRatingService()) {
        self.ratedUser = ratedUser
        self.ratingService = ratingService
    }

    var canSubmit: Bool {
        rating > 0
    }

    func submitRating() async {
        guard canSubmit else { return }

        isSubmitting = true
        errorMessage = nil

        let trimmedComment = comment.trimmingCharacters(in: .whitespacesAndNewlines)
        let commentToSend: String? = trimmedComment.isEmpty ? nil : trimmedComment

        do {
            _ = try await ratingService.submitRating(
                ratedUserId: ratedUser.id,
                score: rating,
                comment: commentToSend
            )
            didSubmit = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isSubmitting = false
    }
}
