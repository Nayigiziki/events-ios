import SwiftData
import SwiftUI

@main
struct DateNightApp: App {
    @StateObject private var claudeService = ClaudeService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(claudeService)
        }

        .modelContainer(for: [ChatMessage.self])
    }
}
