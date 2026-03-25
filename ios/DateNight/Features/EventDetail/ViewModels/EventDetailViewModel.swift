import Foundation
import SwiftUI

@MainActor
final class EventDetailViewModel: ObservableObject {
    @Published var event: Event?
    @Published var showCreateDate = false
    @Published var dateType: DateType = .solo
    @Published var groupSize = 2
    @Published var dateDescription = ""

    enum DateType: String, CaseIterable {
        case solo = "Solo"
        case group = "Group"
    }

    init(event: Event) {
        self.event = event
    }

    func createDate() {
        // Mock implementation - will connect to backend later
        showCreateDate = false
        dateDescription = ""
        dateType = .solo
        groupSize = 2
    }
}
