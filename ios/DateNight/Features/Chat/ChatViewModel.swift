import Foundation
import SwiftData

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var input: String = ""
    @Published var isStreaming = false
    @Published var streamingText = ""
    @Published var errorMessage: String?

    private let claudeService: ClaudeService
    private let modelContext: ModelContext

    init(claudeService: ClaudeService, modelContext: ModelContext) {
        self.claudeService = claudeService
        self.modelContext = modelContext
        loadMessages()
    }

    func loadMessages() {
        let descriptor = FetchDescriptor<ChatMessage>(
            sortBy: [SortDescriptor(\.timestamp)]
        )
        messages = (try? modelContext.fetch(descriptor)) ?? []
    }

    func sendMessage() async {
        guard !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard claudeService.isConfigured else {
            errorMessage = "Please configure your API key in Settings"
            return
        }

        let userMessage = ChatMessage(role: "user", content: input)
        modelContext.insert(userMessage)
        messages.append(userMessage)
        input = ""
        errorMessage = nil

        // Create placeholder for assistant response
        let assistantMessage = ChatMessage(role: "assistant", content: "")
        modelContext.insert(assistantMessage)
        messages.append(assistantMessage)

        isStreaming = true
        streamingText = ""

        do {
            // Build conversation history
            let history = messages.dropLast().map { ($0.role, $0.content) }

            let fullResponse = try await claudeService.streamChat(
                message: userMessage.content,
                conversationHistory: Array(history)
            ) { token in
                self.streamingText += token
                assistantMessage.content = self.streamingText
            }

            assistantMessage.content = fullResponse
            try modelContext.save()
        } catch {
            Logger.error("Chat error", data: ["error": error.localizedDescription])
            errorMessage = error.localizedDescription
            messages.removeLast() // Remove failed assistant message
            modelContext.delete(assistantMessage)
        }

        isStreaming = false
        streamingText = ""
    }

    func clearHistory() {
        do {
            try modelContext.delete(model: ChatMessage.self)
            messages.removeAll()
            try modelContext.save()
        } catch {
            Logger.error("Failed to clear chat history", data: ["error": error.localizedDescription])
        }
    }
}
