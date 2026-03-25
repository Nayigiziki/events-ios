import SwiftUI

struct MatchPreferencesView: View {
    @StateObject private var viewModel = MatchPreferencesViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        DNScreen {
            ScrollView(showsIndicators: false) {
                VStack(spacing: DNSpace.xl) {
                    ageRangeSection
                    distanceSection
                    relationshipTypeSection
                    interestsSection
                    saveButton
                }
                .padding(.horizontal, DNSpace.lg)
                .padding(.top, DNSpace.md)
                .padding(.bottom, DNSpace.xxl * 3)
            }
        }
        .navigationTitle("Match Preferences")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Age Range

    private var ageRangeSection: some View {
        DNCard {
            VStack(alignment: .leading, spacing: DNSpace.md) {
                HStack {
                    Text("AGE RANGE")
                        .dnLabel()
                    Spacer()
                    Text("\(Int(viewModel.ageMin)) - \(Int(viewModel.ageMax))")
                        .dnBody()
                }

                DualSlider(
                    low: $viewModel.ageMin,
                    high: $viewModel.ageMax,
                    range: 18 ... 60
                )
            }
        }
    }

    // MARK: - Distance

    private var distanceSection: some View {
        DNCard {
            VStack(alignment: .leading, spacing: DNSpace.md) {
                HStack {
                    Text("MAXIMUM DISTANCE")
                        .dnLabel()
                    Spacer()
                    Text("\(Int(viewModel.distance)) km")
                        .dnBody()
                }

                Slider(value: $viewModel.distance, in: 1 ... 100, step: 1)
                    .tint(.dnPrimary)
            }
        }
    }

    // MARK: - Relationship Type

    private var relationshipTypeSection: some View {
        DNCard {
            VStack(alignment: .leading, spacing: DNSpace.md) {
                Text("RELATIONSHIP TYPE")
                    .dnLabel()

                FlowLayout(spacing: DNSpace.sm) {
                    ForEach(viewModel.relationshipTypes, id: \.self) { type in
                        FilterChip(
                            title: type,
                            isActive: Binding(
                                get: { viewModel.selectedTypes.contains(type) },
                                set: { _ in viewModel.toggleType(type) }
                            )
                        )
                    }
                }
            }
        }
    }

    // MARK: - Interests

    private var interestsSection: some View {
        DNCard {
            VStack(alignment: .leading, spacing: DNSpace.md) {
                Text("INTERESTS")
                    .dnLabel()

                FlowLayout(spacing: DNSpace.sm) {
                    ForEach(viewModel.interestCategories, id: \.self) { interest in
                        FilterChip(
                            title: interest,
                            isActive: Binding(
                                get: { viewModel.selectedInterests.contains(interest) },
                                set: { _ in viewModel.toggleInterest(interest) }
                            )
                        )
                    }
                }
            }
        }
    }

    // MARK: - Save

    private var saveButton: some View {
        DNButton("Save", variant: .primary) {
            Task {
                await viewModel.save()
                dismiss()
            }
        }
        .opacity(viewModel.isSaving ? 0.6 : 1.0)
        .disabled(viewModel.isSaving)
    }
}

// MARK: - Dual Slider

private struct DualSlider: View {
    @Binding var low: Double
    @Binding var high: Double
    let range: ClosedRange<Double>

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let lowFraction = CGFloat((low - range.lowerBound) / (range.upperBound - range.lowerBound))
            let highFraction = CGFloat((high - range.lowerBound) / (range.upperBound - range.lowerBound))

            ZStack(alignment: .leading) {
                // Track background
                Capsule()
                    .fill(Color.dnMuted)
                    .frame(height: 4)

                // Active range
                Capsule()
                    .fill(Color.dnPrimary)
                    .frame(
                        width: max(0, (highFraction - lowFraction) * width),
                        height: 4
                    )
                    .offset(x: lowFraction * width)

                // Low thumb
                Circle()
                    .fill(Color.white)
                    .frame(width: 24, height: 24)
                    .dnNeuRaised(intensity: .medium, cornerRadius: DNRadius.full)
                    .offset(x: lowFraction * width - 12)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newValue = range
                                    .lowerBound + Double(value.location.x / width) *
                                    (range.upperBound - range.lowerBound)
                                low = min(max(newValue, range.lowerBound), high - 1)
                            }
                    )

                // High thumb
                Circle()
                    .fill(Color.white)
                    .frame(width: 24, height: 24)
                    .dnNeuRaised(intensity: .medium, cornerRadius: DNRadius.full)
                    .offset(x: highFraction * width - 12)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newValue = range
                                    .lowerBound + Double(value.location.x / width) *
                                    (range.upperBound - range.lowerBound)
                                high = max(min(newValue, range.upperBound), low + 1)
                            }
                    )
            }
        }
        .frame(height: 32)
    }
}
