import Foundation

@MainActor
class ProfileEditViewModel: ObservableObject {
    @Published var name: String
    @Published var bio: String
    @Published var occupation: String
    @Published var height: String
    @Published var photos: [String]
    @Published var interests: [String]
    @Published var isReadyToMingle: Bool
    @Published var availableFrom: Date
    @Published var availableUntil: Date
    @Published var newInterest: String = ""

    init() {
        let user = MockData.currentUser
        self.name = user.name
        self.bio = user.bio
        self.occupation = "Designer"
        self.height = "170"
        self.photos = user.photos
        self.interests = user.interests
        self.isReadyToMingle = true
        self.availableFrom = Date()
        self.availableUntil = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    }

    func saveProfile() {
        // Mock save
    }

    func addPhoto() {
        // Mock add photo
    }

    func removePhoto(at index: Int) {
        guard index < photos.count else { return }
        photos.remove(at: index)
    }

    func addInterest() {
        let trimmed = newInterest.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !interests.contains(trimmed) else { return }
        interests.append(trimmed)
        newInterest = ""
    }

    func removeInterest(_ interest: String) {
        interests.removeAll { $0 == interest }
    }
}
