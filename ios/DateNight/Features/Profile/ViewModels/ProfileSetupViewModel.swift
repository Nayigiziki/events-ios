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

    static let allInterests = [
        "Music", "Art", "Food", "Comedy", "Wine", "Wellness",
        "Sports", "Travel", "Photography", "Dancing",
        "Theater", "Outdoors", "Gaming", "Reading", "Cooking", "Yoga"
    ]

    static let maxPhotos = 6
    static let minPhotos = 2
    static let minInterests = 3
    static let totalSteps = 3

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
        // Mock: add a placeholder photo URL
        let placeholderURL = "https://picsum.photos/seed/\(UUID().uuidString.prefix(8))/400/400"
        photos.append(placeholderURL)
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
        isLoading = true

        // Mock implementation — simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        // FUTURE: Save profile to Supabase when backend is ready
        print("[ProfileSetupViewModel] Profile setup complete")
        print("  Photos: \(photos.count)")
        print("  Bio: \(bio)")
        print("  Occupation: \(occupation)")
        print("  Location: \(location)")
        print("  Height: \(height)")
        print("  Interests: \(selectedInterests)")

        isLoading = false

        // Mark profile as complete
        UserDefaults.standard.set(true, forKey: "profileComplete")
    }
}
