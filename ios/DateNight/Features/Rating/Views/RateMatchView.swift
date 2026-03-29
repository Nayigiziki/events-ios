import SwiftUI

struct RateMatchView: View {
    @StateObject private var viewModel: RateMatchViewModel
    @Environment(\.dismiss) private var dismiss

    init(ratedUser: UserProfile) {
        _viewModel = StateObject(wrappedValue: RateMatchViewModel(ratedUser: ratedUser))
    }

    var body: some View {
        DNScreen {
            ScrollView {
                VStack(spacing: DNSpace.xl) {
                    Spacer().frame(height: DNSpace.lg)

                    AvatarView(
                        url: URL(string: viewModel.ratedUser.avatarUrl ?? ""),
                        size: 96
                    )

                    VStack(spacing: DNSpace.sm) {
                        Text(viewModel.ratedUser.name)
                            .dnH2()

                        Text("How was your date?")
                            .dnBody()
                    }

                    // Star rating
                    HStack(spacing: DNSpace.md) {
                        ForEach(1 ... 5, id: \.self) { star in
                            Image(systemName: star <= viewModel.rating ? "star.fill" : "star")
                                .font(.system(size: 40))
                                .foregroundColor(star <= viewModel.rating ? .dnWarning : .dnMuted)
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.15)) {
                                        viewModel.rating = star
                                    }
                                }
                        }
                    }
                    .padding(.vertical, DNSpace.sm)

                    // Comment field
                    VStack(alignment: .leading, spacing: DNSpace.sm) {
                        Text("COMMENTS")
                            .dnLabel()

                        TextEditor(text: $viewModel.comment)
                            .font(.system(size: 16, weight: .semibold))
                            .tracking(-0.47)
                            .foregroundColor(.dnTextPrimary)
                            .frame(height: 90)
                            .padding(DNSpace.md)
                            .scrollContentBackground(.hidden)
                            .background(Color.dnBackground)
                            .dnNeuPressed(intensity: .medium, cornerRadius: DNRadius.md)
                            .overlay(alignment: .topLeading) {
                                if viewModel.comment.isEmpty {
                                    Text("Share your experience...")
                                        .font(.system(size: 16, weight: .semibold))
                                        .tracking(-0.47)
                                        .foregroundColor(.dnTextTertiary)
                                        .padding(.horizontal, DNSpace.lg)
                                        .padding(.top, DNSpace.lg)
                                        .allowsHitTesting(false)
                                }
                            }
                    }
                    .padding(.horizontal, DNSpace.lg)

                    Spacer().frame(height: DNSpace.md)

                    // Buttons
                    VStack(spacing: DNSpace.md) {
                        DNButton("Submit Rating", variant: .primary) {
                            Task {
                                await viewModel.submitRating()
                                if viewModel.didSubmit {
                                    dismiss()
                                }
                            }
                        }
                        .opacity(viewModel.canSubmit ? 1.0 : 0.5)
                        .disabled(!viewModel.canSubmit)

                        DNButton("Skip", variant: .secondary) {
                            dismiss()
                        }
                    }
                    .padding(.horizontal, DNSpace.lg)
                }
                .padding(.horizontal, DNSpace.lg)
            }
        }
    }
}
