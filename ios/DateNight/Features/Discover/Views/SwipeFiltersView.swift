import SwiftUI

struct SwipeFiltersView: View {
    @Binding var showFilters: Bool

    @State private var minAge: Double = 21
    @State private var maxAge: Double = 40
    @State private var distance: Double = 25
    @State private var selectedInterests: Set<String> = []

    private let allInterests = [
        "Music", "Art", "Food", "Comedy",
        "Wine", "Outdoors", "Wellness", "Sports",
        "Theater", "Travel", "Dining", "Yoga"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Filters")
                    .dnH3()
                Spacer()
                Button {
                    withAnimation(.dnModalPresent) {
                        showFilters = false
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.dnTextSecondary)
                }
            }
            .padding(.bottom, DNSpace.lg)

            // Age Range
            DNCard {
                VStack(alignment: .leading, spacing: DNSpace.sm) {
                    HStack {
                        Text("Age")
                            .dnCaption()
                        Spacer()
                        Text("\(Int(minAge)) - \(Int(maxAge))")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.dnPrimary)
                    }

                    VStack(spacing: DNSpace.xs) {
                        HStack {
                            Text("Min")
                                .dnSmall()
                            Slider(value: $minAge, in: 18 ... 60, step: 1)
                                .tint(.dnPrimary)
                        }
                        HStack {
                            Text("Max")
                                .dnSmall()
                            Slider(value: $maxAge, in: 18 ... 60, step: 1)
                                .tint(.dnPrimary)
                        }
                    }
                }
            }
            .padding(.bottom, DNSpace.md)

            // Distance
            DNCard {
                VStack(alignment: .leading, spacing: DNSpace.sm) {
                    HStack {
                        Text("Distance")
                            .dnCaption()
                        Spacer()
                        Text("\(Int(distance)) km")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.dnPrimary)
                    }

                    Slider(value: $distance, in: 1 ... 100, step: 1)
                        .tint(.dnPrimary)
                }
            }
            .padding(.bottom, DNSpace.md)

            // Interests
            DNCard {
                VStack(alignment: .leading, spacing: DNSpace.sm) {
                    Text("Interests")
                        .dnCaption()

                    FlowLayout(spacing: DNSpace.sm) {
                        ForEach(allInterests, id: \.self) { interest in
                            let isActive = selectedInterests.contains(interest)
                            Button {
                                if isActive {
                                    selectedInterests.remove(interest)
                                } else {
                                    selectedInterests.insert(interest)
                                }
                            } label: {
                                Text(interest)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(isActive ? .dnPrimary : .dnTextSecondary)
                                    .padding(.horizontal, DNSpace.lg)
                                    .padding(.vertical, DNSpace.sm)
                            }
                            .buttonStyle(.plain)
                            .if(isActive) { view in
                                view.dnNeuPressed(cornerRadius: DNRadius.full)
                            }
                            .if(!isActive) { view in
                                view.dnNeuRaised(cornerRadius: DNRadius.full)
                            }
                        }
                    }
                }
            }
            .padding(.bottom, DNSpace.lg)

            // Apply button
            DNButton("Apply", variant: .primary) {
                withAnimation(.dnModalPresent) {
                    showFilters = false
                }
            }
        }
        .padding(DNSpace.lg)
        .background(Color.dnBackground)
        .clipShape(RoundedRectangle(cornerRadius: DNRadius.xl, style: .continuous))
        .dnNeuRaised(cornerRadius: DNRadius.xl)
        .padding(.horizontal, DNSpace.lg)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

// MARK: - FlowLayout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func arrangeSubviews(
        proposal: ProposedViewSize,
        subviews: Subviews
    ) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentX + size.width > maxWidth, currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
        }

        return (
            size: CGSize(width: maxWidth, height: currentY + lineHeight),
            positions: positions
        )
    }
}

// MARK: - Conditional Modifier

extension View {
    @ViewBuilder
    func `if`(_ condition: Bool, transform: (Self) -> some View) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
