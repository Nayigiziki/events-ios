import Foundation

struct FeedbackMessage: Identifiable {
    let id = UUID().uuidString
    let text: String
    let isUser: Bool
    let timestamp = Date()
}

@MainActor
final class FeedbackChatViewModel: ObservableObject {
    @Published var messages: [FeedbackMessage] = []
    @Published var inputText = ""
    @Published var isStreaming = false
    @Published var streamingText = ""

    private let claudeService = ClaudeService(preferDirectAPI: true)

    private let systemPrompt = """
    You are the DateNight feedback assistant. DateNight is an event-based dating app where users \
    discover events, match with other people, and create dates to attend events together.

    Your job is to collect user feedback about the app. Be warm, conversational, and curious. \
    Ask follow-up questions to understand their experience deeply. Focus on:

    1. What they like about the app
    2. What frustrates them or feels confusing
    3. What features they wish existed
    4. How the app compares to other dating apps they've used
    5. Specific UI/UX pain points

    Keep responses concise (2-3 sentences max). Ask ONE follow-up question at a time. \
    Don't be overly formal. Use a friendly, casual tone. \
    If they share a bug, acknowledge it and ask for steps to reproduce. \
    End each response with a specific question to keep the conversation going.

    IMPORTANT: You are purely a feedback collector. Do not offer to fix things or make promises \
    about future features. Just listen, understand, and ask good questions.
    """

    var canSend: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isStreaming
    }

    init() {
        // Welcome message
        messages.append(FeedbackMessage(
            text: "Hey! 👋 I'm here to hear about your DateNight experience. What's on your mind — anything you love, hate, or wish was different?",
            isUser: false
        ))
    }

    func sendMessage() async {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        // Add user message
        messages.append(FeedbackMessage(text: text, isUser: true))
        inputText = ""
        isStreaming = true
        streamingText = ""

        // Build conversation history
        let history: [(role: String, content: String)] = messages.dropLast().map { msg in
            (role: msg.isUser ? "user" : "assistant", content: msg.text)
        }

        do {
            guard claudeService.isConfigured else {
                // Fallback if no API key
                messages.append(FeedbackMessage(
                    text: "Thanks for sharing that! I'm not connected to Claude right now (API key needed), but your feedback has been noted. What else would you like to share?",
                    isUser: false
                ))
                isStreaming = false
                return
            }

            var response = ""
            try await claudeService.streamChat(
                message: text,
                systemPrompt: systemPrompt,
                conversationHistory: history,
                maxTokens: 300
            ) { [weak self] token in
                response += token
                self?.streamingText = response

                // Add streaming message on first token
                if response == token {
                    self?.messages.append(FeedbackMessage(text: response, isUser: false))
                }

                // Update the last assistant message in real-time
                if let lastIndex = self?.messages.lastIndex(where: { !$0.isUser }) {
                    self?.messages[lastIndex] = FeedbackMessage(text: response, isUser: false)
                }
            }

            // Final update with complete response
            if let lastIndex = messages.lastIndex(where: { !$0.isUser }) {
                messages[lastIndex] = FeedbackMessage(text: response, isUser: false)
            }

        } catch {
            messages.append(FeedbackMessage(
                text: "Sorry, I had a hiccup! Could you try sending that again?",
                isUser: false
            ))
        }

        isStreaming = false
    }
}
