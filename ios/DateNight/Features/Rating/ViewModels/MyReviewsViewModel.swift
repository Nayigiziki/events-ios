import Foundation

@MainActor
final class MyReviewsViewModel: ObservableObject {
    @Published var reviews: [DateReview] = []
    @Published var averageRating: Double = 0.0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let reviewService: any ReviewServiceProtocol
    private let userId: UUID

    init(reviewService: any ReviewServiceProtocol = SupabaseReviewService(), userId: UUID = UUID()) {
        self.reviewService = reviewService
        self.userId = userId
    }

    func loadReviews() async {
        isLoading = true
        errorMessage = nil
        do {
            reviews = try await reviewService.fetchReviews(forUserId: userId)
            if reviews.isEmpty {
                averageRating = 0.0
            } else {
                let total = reviews.reduce(0) { $0 + $1.stars }
                averageRating = Double(total) / Double(reviews.count)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
