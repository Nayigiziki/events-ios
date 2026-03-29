import SwiftUI

struct SwipeFiltersView: View {
    @Binding var showFilters: Bool
    @Binding var filters: DiscoverFilters
    var onApply: (() -> Void)?

    @State private var minAge: Double
    @State private var maxAge: Double
    @State private var distance: Double
    @State private var selectedInterests: Set<String>
    @State private var genderPreference: String?

    private let allInterests = [
        "Music", "Art", "Food", "Comedy",
        "Wine", "Outdoors", "Wellness", "Sports",
        "Theater", "Travel", "Dining", "Yoga"
    ]

    private let genderOptions = [
        ("filter_gender_all".localized(), nil as String?),
        ("auth_gender_male".localized(), Optional("male")),
        ("auth_gender_female".localized(), Optional("female")),
        ("auth_gender_nonbinary".localized(), Optional("non-binary"))
    ]

    init(showFilters: Binding<Bool>, filters: Binding<DiscoverFilters>, onApply: (() -> Void)? = nil) {
        _showFilters = showFilters
        _filters = filters
        _minAge = State(initialValue: Double(filters.wrappedValue.minAge))
        _maxAge = State(initialValue: Double(filters.wrappedValue.maxAge))
        _distance = State(initialValue: Double(filters.wrappedValue.maxDistance))
        _selectedInterests = State(initialValue: filters.wrappedValue.interests)
        _genderPreference = State(initialValue: filters.wrappedValue.genderPreference)
        self.onApply = onApply
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("filter_title".localized())
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
                        Text("filter_age".localized())
                            .dnCaption()
                        Spacer()
                        Text("\(Int(minAge)) - \(Int(maxAge))")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.dnPrimary)
                    }

                    VStack(spacing: DNSpace.xs) {
                        HStack {
                            Text("filter_min".localized())
                                .dnSmall()
                            Slider(value: $minAge, in: 18 ... 60, step: 1)
                                .tint(.dnPrimary)
                        }
                        HStack {
                            Text("filter_max".localized())
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
                        Text("filter_distance".localized())
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

            // Gender Preference (#52)
            DNCard {
                VStack(alignment: .leading, spacing: DNSpace.sm) {
                    Text("filter_gender_preference".localized())
                        .dnCaption()

                    FlowLayout(spacing: DNSpace.sm) {
                        ForEach(genderOptions, id: \.0) { label, value in
                            let isActive = genderPreference == value
                            Button {
                                genderPreference = value
                            } label: {
                                Text(label)
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
            .padding(.bottom, DNSpace.md)

            // Interests
            DNCard {
                VStack(alignment: .leading, spacing: DNSpace.sm) {
                    Text("filter_interests".localized())
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
            DNButton("button_apply".localized(), variant: .primary) {
                filters = DiscoverFilters(
                    minAge: Int(minAge),
                    maxAge: Int(maxAge),
                    maxDistance: Int(distance),
                    interests: selectedInterests,
                    genderPreference: genderPreference
                )
                withAnimation(.dnModalPresent) {
                    showFilters = false
                }
                onApply?()
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
