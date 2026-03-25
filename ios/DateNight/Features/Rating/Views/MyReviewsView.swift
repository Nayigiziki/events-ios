import SwiftUI

struct MyReviewsView: View {
    @StateObject private var viewModel = MyReviewsViewModel()

    var body: some View {
        DNScreen {
            ScrollView {
                VStack(spacing: DNSpace.xl) {
                    Text("MY REVIEWS")
                        .dnH2()
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // Average rating card
                    DNCard {
                        HStack(spacing: DNSpace.lg) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.dnWarning)

                            VStack(alignment: .leading, spacing: DNSpace.xs) {
                                Text(String(format: "%.1f", viewModel.averageRating))
                                    .font(.system(size: 48, weight: .black))
                                    .tracking(-0.85)
                                    .foregroundColor(.dnTextPrimary)

                                Text("Based on \(viewModel.reviews.count) reviews")
                                    .dnCaption()
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Reviews list
                    if viewModel.reviews.isEmpty {
                        emptyState
                    } else {
                        LazyVStack(spacing: DNSpace.lg) {
                            ForEach(viewModel.reviews) { review in
                                reviewCard(review)
                            }
                        }
                    }
                }
                .padding(DNSpace.lg)
            }
        }
    }

    private func reviewCard(_ review: MockReview) -> some View {
        DNCard {
            VStack(alignment: .leading, spacing: DNSpace.md) {
                HStack(spacing: DNSpace.md) {
                    AvatarView(url: URL(string: review.reviewerAvatar), size: 40)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(review.reviewerName)
                            .dnH3()
                        Text(review.date)
                            .dnSmall()
                    }

                    Spacer()
                }

                // Stars
                HStack(spacing: 4) {
                    ForEach(1 ... 5, id: \.self) { star in
                        Image(systemName: star <= review.stars ? "star.fill" : "star")
                            .font(.system(size: 14))
                            .foregroundColor(star <= review.stars ? .dnWarning : .dnMuted)
                    }
                }

                if let comment = review.comment {
                    Text(comment)
                        .dnBody()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var emptyState: some View {
        VStack(spacing: DNSpace.lg) {
            Spacer().frame(height: 60)

            Image(systemName: "star.slash")
                .font(.system(size: 48))
                .foregroundColor(.dnMuted)

            Text("No reviews yet")
                .dnBody()

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    MyReviewsView()
}
