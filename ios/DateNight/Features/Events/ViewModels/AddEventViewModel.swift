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
    @Published var totalSpots = "100"
    @Published var isCreating = false
    @Published var didCreate = false
    @Published var errorMessage: String?

    let categories = ["Music", "Art", "Comedy", "Food", "Wellness", "Wine", "Social"]

    private let eventService: any EventServiceProtocol
    private let editingEvent: Event?

    var isEditing: Bool { editingEvent != nil }

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
            && !venue.trimmingCharacters(in: .whitespaces).isEmpty
    }

    init(eventService: any EventServiceProtocol = SupabaseEventService(), event: Event? = nil) {
        self.eventService = eventService
        self.editingEvent = event

        if let event {
            self.title = event.title
            self.description = event.description
            self.selectedCategory = event.category
            self.venue = event.venue
            self.location = event.location
            self.price = event.price
            self.isPublic = event.isPublic
            self.totalSpots = "\(event.totalSpots)"
        }
    }

    func save() async {
        if isEditing {
            await updateEvent()
        } else {
            await createEvent()
        }
    }

    func createEvent() async {
        guard isValid else { return }
        isCreating = true
        errorMessage = nil

        do {
            var imageUrl: String?
            if let image = selectedImage, let data = image.jpegData(compressionQuality: 0.8) {
                imageUrl = try await eventService.uploadEventImage(data)
            }

            let request = buildRequest(imageUrl: imageUrl)
            _ = try await eventService.createEvent(request)
            didCreate = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isCreating = false
    }

    private func updateEvent() async {
        guard isValid, let eventId = editingEvent?.id else { return }
        isCreating = true
        errorMessage = nil

        do {
            var imageUrl: String? = editingEvent?.imageUrl
            if let image = selectedImage, let data = image.jpegData(compressionQuality: 0.8) {
                imageUrl = try await eventService.uploadEventImage(data)
            }

            let request = buildRequest(imageUrl: imageUrl)
            _ = try await eventService.updateEvent(eventId, request)
            didCreate = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isCreating = false
    }

    private func buildRequest(imageUrl: String?) -> EventCreateRequest {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short

        return EventCreateRequest(
            title: title,
            category: selectedCategory,
            imageUrl: imageUrl,
            date: dateFormatter.string(from: eventDate),
            time: timeFormatter.string(from: eventTime),
            venue: venue,
            location: location.isEmpty ? venue : location,
            price: price.isEmpty ? "Free" : price,
            description: description,
            totalSpots: Int(totalSpots) ?? 100,
            isPublic: isPublic
        )
    }
}
