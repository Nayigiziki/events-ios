import Foundation

@MainActor
class MatchPreferencesViewModel: ObservableObject {
    @Published var ageMin: Double = 18
    @Published var ageMax: Double = 35
    @Published var distance: Double = 25
    @Published var selectedTypes: Set<String> = []
    @Published var selectedInterests: Set<String> = []
    @Published var isSaving: Bool = false

    let relationshipTypes = ["Casual", "Serious", "Friendship", "Activity Partner"]

    let interestCategories = [
        "Music", "Art", "Comedy", "Food",
        "Wellness", "Wine", "Social", "Outdoors",
        "Sports", "Travel", "Theater", "Yoga",
        "Jazz", "Dining", "Photography", "Gaming"
    ]

    func toggleType(_ type: String) {
        if selectedTypes.contains(type) {
            selectedTypes.remove(type)
        } else {
            selectedTypes.insert(type)
        }
    }

    func toggleInterest(_ interest: String) {
        if selectedInterests.contains(interest) {
            selectedInterests.remove(interest)
        } else {
            selectedInterests.insert(interest)
        }
    }

    func save() async {
        isSaving = true
        // Mock save — simulate network delay
        try? await Task.sleep(nanoseconds: 500_000_000)
        isSaving = false
        print(
            "Preferences saved: age \(Int(ageMin))-\(Int(ageMax)), distance \(Int(distance))km, types \(selectedTypes), interests \(selectedInterests)"
        )
    }
}
