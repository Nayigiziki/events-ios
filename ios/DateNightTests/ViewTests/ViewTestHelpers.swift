@testable import DateNight
import SwiftUI
import UIKit
import XCTest

// MARK: - Test Fixtures

enum TestFixtures {
    static var testUser: UserProfile {
        UserProfile(
            id: UUID(),
            name: "Test User",
            age: 25,
            bio: "Test bio",
            avatarUrl: "https://example.com/avatar.jpg",
            photos: ["https://example.com/photo1.jpg"],
            interests: ["Music", "Art"]
        )
    }

    static var testEvent: Event {
        Event(
            title: "Test Event",
            category: "Music",
            imageUrl: "https://example.com/event.jpg",
            date: "2026-04-01",
            time: "20:00",
            venue: "Test Venue",
            location: "Test Location",
            price: "$25",
            description: "A test event",
            totalSpots: 100
        )
    }

    static var testDateRequest: DateRequest {
        DateRequest(
            id: UUID(),
            eventId: UUID(),
            organizerId: UUID(),
            maxPeople: 4,
            description: "Test date",
            dateType: .group,
            status: .open,
            organizer: testUser,
            event: testEvent,
            attendees: [testUser]
        )
    }

    static var testMessage: Message {
        Message(
            id: UUID(),
            conversationId: UUID(),
            senderId: UUID(),
            content: "Hello",
            messageType: .text,
            createdAt: Date()
        )
    }

    @MainActor
    static func makeAuthViewModel() -> AuthViewModel {
        AuthViewModel(
            authService: MockAuthService(),
            profileService: MockProfileService(),
            biometricService: MockBiometricAuthService(),
            rememberMeService: RememberMeService()
        )
    }
}

// MARK: - UIHostingController render helper

extension XCTestCase {
    /// Forces a SwiftUI view to render inside a UIHostingController.
    /// Returns the hosting controller so tests can assert on its view.
    @MainActor
    func renderView<V: View>(_ view: V) -> UIHostingController<V> {
        let hosting = UIHostingController(rootView: view)
        hosting.loadViewIfNeeded()
        return hosting
    }
}
