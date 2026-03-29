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
    @Published var isUploadingPhoto: Bool = false
    @Published var isSaving: Bool = false
    @Published var errorMessage: String?

    private let profileService: any ProfileServiceProtocol
    var userId: UUID?

    static let maxPhotos = 6

    init(profileService: any ProfileServiceProtocol = ProfileService(), userId: UUID? = nil) {
        self.profileService = profileService
        self.userId = userId
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
        guard let userId else { return }
        isSaving = true
        errorMessage = nil

        let request = ProfileUpdateRequest(
            name: name.isEmpty ? nil : name,
            bio: bio.isEmpty ? nil : bio,
            occupation: occupation.isEmpty ? nil : occupation,
            height: Int(height),
            photos: photos,
            interests: interests,
            readyToMingle: isReadyToMingle,
            availableFrom: isReadyToMingle ? availableFrom : nil,
            availableUntil: isReadyToMingle ? availableUntil : nil
        )

        Task {
            do {
                try await profileService.updateProfile(request, userId: userId)
            } catch {
                errorMessage = error.localizedDescription
            }
            isSaving = false
        }
    }

    func addPhotoData(_ data: Data) async {
        guard photos.count < Self.maxPhotos else { return }
        guard let userId else {
            errorMessage = "No user session found"
            return
        }

        isUploadingPhoto = true
        errorMessage = nil

        do {
            let url = try await profileService.uploadPhoto(data: data, userId: userId)
            photos.append(url)
        } catch {
            errorMessage = error.localizedDescription
        }

        isUploadingPhoto = false
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
