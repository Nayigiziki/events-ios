import Foundation
import SwiftUI

@MainActor
final class ProfileSetupViewModel: ObservableObject {
    @Published var currentStep: Int = 0
    @Published var photos: [String] = []
    @Published var bio: String = ""
    @Published var occupation: String = ""
    @Published var location: String = ""
    @Published var height: String = ""
    @Published var selectedInterests: Set<String> = []
    @Published var isLoading: Bool = false
    @Published var isUploadingPhoto: Bool = false
    @Published var isComplete: Bool = false
    @Published var errorMessage: String?

    private let profileService: any ProfileServiceProtocol
    var userId: UUID?

    static let allInterests = [
        "Music", "Art", "Food", "Comedy", "Wine", "Wellness",
        "Sports", "Travel", "Photography", "Dancing",
        "Theater", "Outdoors", "Gaming", "Reading", "Cooking", "Yoga"
    ]

    static let maxPhotos = 6
    static let minPhotos = 2
    static let minInterests = 3
    static let totalSteps = 3

    init(
        profileService: any ProfileServiceProtocol = ProfileService(),
        userId: UUID? = nil
    ) {
        self.profileService = profileService
        self.userId = userId
    }

    var canProceed: Bool {
        switch currentStep {
        case 0:
            photos.count >= Self.minPhotos
        case 1:
            !bio.isEmpty
        case 2:
            selectedInterests.count >= Self.minInterests
        default:
            false
        }
    }

    func addPhoto() {
        guard photos.count < Self.maxPhotos else { return }
        let placeholderURL = "https://picsum.photos/seed/\(UUID().uuidString.prefix(8))/400/400"
        photos.append(placeholderURL)
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
        guard index >= 0, index < photos.count else { return }
        photos.remove(at: index)
    }

    func toggleInterest(_ interest: String) {
        if selectedInterests.contains(interest) {
            selectedInterests.remove(interest)
        } else {
            selectedInterests.insert(interest)
        }
    }

    func nextStep() {
        guard currentStep < Self.totalSteps - 1 else { return }
        currentStep += 1
    }

    func previousStep() {
        guard currentStep > 0 else { return }
        currentStep -= 1
    }

    func completeSetup() async {
        guard let userId else {
            errorMessage = "No user session found"
            return
        }

        isLoading = true
        errorMessage = nil

        let request = ProfileUpdateRequest(
            name: nil,
            bio: bio.isEmpty ? nil : bio,
            occupation: occupation.isEmpty ? nil : occupation,
            height: Int(height),
            photos: photos,
            interests: Array(selectedInterests),
            readyToMingle: true,
            availableFrom: nil,
            availableUntil: nil
        )

        do {
            try await profileService.updateProfile(request, userId: userId)
            isComplete = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
