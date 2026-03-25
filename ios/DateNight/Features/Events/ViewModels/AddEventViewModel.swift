import Foundation
import SwiftUI

@MainActor
final class AddEventViewModel: ObservableObject {
    @Published var title = ""
    @Published var description = ""
    @Published var selectedCategory = "Music"
    @Published var eventDate = Date()
    @Published var eventTime = Date()
    @Published var venue = ""
    @Published var location = ""
    @Published var selectedImage: UIImage?
    @Published var price = ""
    @Published var isPublic = true
    @Published var isCreating = false
    @Published var didCreate = false

    let categories = ["Music", "Art", "Comedy", "Food", "Wellness", "Wine", "Social"]

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
            && !venue.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func createEvent() async {
        guard isValid else { return }
        isCreating = true
        // Mock network delay
        try? await Task.sleep(nanoseconds: 800_000_000)
        isCreating = false
        didCreate = true
    }
}
