import Foundation

struct MockReview: Identifiable {
    let id: String
    let reviewerName: String
    let reviewerAvatar: String
    let stars: Int
    let comment: String?
    let date: String
}

@MainActor
final class MyReviewsViewModel: ObservableObject {
    @Published var averageRating: Double = 4.5
    @Published var reviews: [MockReview] = []

    init() {
        loadMockData()
    }

    private func loadMockData() {
        reviews = [
            MockReview(
                id: "r1",
                reviewerName: "Emma",
                reviewerAvatar: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&h=400&fit=crop",
                stars: 5,
                comment: "Amazing date! Great conversation and really fun to be around.",
                date: "Mar 20"
            ),
            MockReview(
                id: "r2",
                reviewerName: "Sarah",
                reviewerAvatar: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&h=400&fit=crop",
                stars: 4,
                comment: "Had a wonderful time at the art gallery. Would love to go again!",
                date: "Mar 15"
            ),
            MockReview(
                id: "r3",
                reviewerName: "Alex",
                reviewerAvatar: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400&h=400&fit=crop",
                stars: 5,
                comment: nil,
                date: "Mar 10"
            ),
            MockReview(
                id: "r4",
                reviewerName: "Michael",
                reviewerAvatar: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&h=400&fit=crop",
                stars: 4,
                comment: "Great energy and picked an awesome restaurant.",
                date: "Mar 5"
            ),
            MockReview(
                id: "r5",
                reviewerName: "Jessica",
                reviewerAvatar: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&h=400&fit=crop",
                stars: 5,
                comment: "So thoughtful and fun. Best date I've had on the app!",
                date: "Feb 28"
            )
        ]

        let total = reviews.reduce(0) { $0 + $1.stars }
        averageRating = Double(total) / Double(reviews.count)
    }
}
