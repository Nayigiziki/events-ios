@testable import DateNight
import SwiftUI
import XCTest

@MainActor
final class EventViewRenderTests: XCTestCase {
    // MARK: - EventDetailView (Features/EventDetail)

    func testEventDetailView_renders_withoutCrash() {
        let view = NavigationStack {
            EventDetailView(event: TestFixtures.testEvent)
        }
        let hosting = renderView(view)
        XCTAssertNotNil(hosting.view)
    }

    // MARK: - AddEventView

    func testAddEventView_renders_withoutCrash() {
        let view = AddEventView()
        let hosting = renderView(view)
        XCTAssertNotNil(hosting.view)
    }

    func testAddEventView_editMode_renders_withoutCrash() {
        let view = AddEventView(event: TestFixtures.testEvent)
        let hosting = renderView(view)
        XCTAssertNotNil(hosting.view)
    }

    // MARK: - EventSwipeCardView

    func testEventSwipeCardView_renders_withoutCrash() {
        let view = EventSwipeCardView(event: TestFixtures.testEvent)
            .frame(width: 300, height: 400)
        let hosting = renderView(view)
        XCTAssertNotNil(hosting.view)
    }

    // MARK: - EventSwipeView

    func testEventSwipeView_renders_withoutCrash() {
        let view = EventSwipeView()
        let hosting = renderView(view)
        XCTAssertNotNil(hosting.view)
    }

    // MARK: - MyEventsView

    func testMyEventsView_renders_withoutCrash() {
        let view = MyEventsView()
        let hosting = renderView(view)
        XCTAssertNotNil(hosting.view)
    }
}
