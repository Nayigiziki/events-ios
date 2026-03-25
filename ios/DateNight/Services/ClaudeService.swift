import Foundation
import SwiftAnthropic

/// Service for interacting with Claude via SwiftAnthropic
/// Handles both streaming and non-streaming chat
@MainActor
class ClaudeService: ObservableObject {
    private var service: AnthropicService?

    @Published var isConfigured = false
    @Published var lastError: String?

    /// Initialize with automatic configuration detection
    /// - Parameter preferDirectAPI: If true, prefer direct API over AIProxy (useful for tests)
    init(preferDirectAPI: Bool = false) {
        setupService(preferDirectAPI: preferDirectAPI)
    }

    private func setupService(preferDirectAPI: Bool) {
        // For tests/development, prefer direct API to avoid DeviceCheck issues
        if preferDirectAPI, Configuration.isDirectAPIConfigured {
            service = AnthropicServiceFactory.service(
                apiKey: Configuration.anthropicAPIKey,
                betaHeaders: nil
            )
            isConfigured = true
            Logger.debug("ClaudeService initialized with direct API key (preferred)")
        } else if Configuration.isAIProxyConfigured {
            // Production: Use AIProxy for secure key management
            service = AnthropicServiceFactory.service(
                aiproxyPartialKey: Configuration.aiproxyPartialKey,
                aiproxyServiceURL: Configuration.aiproxyServiceURL,
                betaHeaders: nil
            )
            isConfigured = true
            Logger.debug("ClaudeService initialized with AIProxy")
        } else if Configuration.isDirectAPIConfigured {
            // Development: Use direct API key (not recommended for production)
            service = AnthropicServiceFactory.service(
                apiKey: Configuration.anthropicAPIKey,
                betaHeaders: nil
            )
            isConfigured = true
            Logger.debug("ClaudeService initialized with direct API key")
        } else {
            isConfigured = false
            Logger.warning("ClaudeService not configured - no API credentials found")
        }
    }

    // MARK: - Simple (Non-Streaming) Chat

    /// Send a message and get a complete response (non-streaming)
    /// - Parameters:
    ///   - message: The user's message
    ///   - systemPrompt: Optional system prompt for context
    ///   - maxTokens: Maximum tokens in response (default: 1024)
    /// - Returns: Complete response text
    func sendMessage(
        _ message: String,
        systemPrompt: String? = nil,
        maxTokens: Int = 1024
    ) async throws -> String {
        guard let service else {
            throw ClaudeError.notConfigured
        }

        let parameters = MessageParameter(
            model: .other("claude-sonnet-4-20250514"),
            messages: [.init(role: .user, content: .text(message))],
            maxTokens: maxTokens,
            system: systemPrompt.map { .text($0) },
            stream: false
        )

        do {
            let response = try await service.createMessage(parameters)
            // Extract text content from response
            if let textBlock = response.content.first(where: { block in
                if case .text = block {
                    return true
                }
                return false
            }), case let .text(text) = textBlock {
                Logger.info("Claude response received", data: [
                    "inputTokens": response.usage.inputTokens,
                    "outputTokens": response.usage.outputTokens
                ])
                return text
            }
            throw ClaudeError.invalidResponse
        } catch {
            lastError = error.localizedDescription
            Logger.error("Claude request failed", data: ["error": error.localizedDescription])
            throw error
        }
    }

    // MARK: - Streaming Chat

    /// Stream a chat response with conversation history
    /// - Parameters:
    ///   - message: The user's message
    ///   - systemPrompt: Optional system prompt for context
    ///   - conversationHistory: Previous messages for context
    ///   - maxTokens: Maximum tokens in response (default: 2048)
    ///   - onToken: Callback for each streamed token
    /// - Returns: The complete response
    @discardableResult
    func streamChat(
        message: String,
        systemPrompt: String? = nil,
        conversationHistory: [(role: String, content: String)] = [],
        maxTokens: Int = 2048,
        onToken: @escaping (String) -> Void
    ) async throws -> String {
        guard let service else {
            throw ClaudeError.notConfigured
        }

        // Build message array with conversation history
        var messages: [MessageParameter.Message] = []

        // Add conversation history
        for (role, content) in conversationHistory {
            let messageRole: MessageParameter.Message.Role = role.lowercased() == "user" ? .user : .assistant
            messages.append(.init(role: messageRole, content: .text(content)))
        }

        // Add current message
        messages.append(.init(role: .user, content: .text(message)))

        let parameters = MessageParameter(
            model: .other("claude-sonnet-4-20250514"),
            messages: messages,
            maxTokens: maxTokens,
            system: systemPrompt.map { .text($0) },
            stream: true
        )

        var fullResponse = ""

        do {
            Logger.debug("Starting Claude stream", data: [
                "messageLength": message.count,
                "historyCount": conversationHistory.count
            ])

            for try await event in try await service.streamMessage(parameters) {
                if let text = event.delta?.text {
                    fullResponse += text
                    onToken(text)
                }
            }

            Logger.info("Claude stream completed", data: [
                "responseLength": fullResponse.count
            ])
        } catch {
            lastError = error.localizedDescription
            Logger.error("Claude stream failed", data: ["error": error.localizedDescription])
            throw error
        }

        return fullResponse
    }
}

// MARK: - Error Types

enum ClaudeError: LocalizedError {
    case notConfigured
    case invalidResponse
    case streamingError(String)

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            "Claude service is not configured. Please add your API key to Secrets.xcconfig."
        case .invalidResponse:
            "Received an invalid response from Claude."
        case let .streamingError(message):
            "Streaming error: \(message)"
        }
    }
}
