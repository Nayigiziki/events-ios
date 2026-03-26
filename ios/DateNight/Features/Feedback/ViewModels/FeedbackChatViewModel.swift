import Foundation
import Supabase
import SwiftAnthropic

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
    @Published var savedFeedbackCount = 0

    private let claudeService = ClaudeService(preferDirectAPI: true)

    // swiftlint:disable line_length
    private let systemPrompt = """
    Eres el asistente de feedback de DateNight. DateNight es una app de citas basada en eventos donde los usuarios descubren eventos, hacen match con otras personas y crean citas para asistir a eventos juntos.

    Tu trabajo es recopilar feedback de los usuarios sobre la app. Sé cálido, conversacional y curioso. Haz preguntas de seguimiento para entender su experiencia a fondo.

    Mantén las respuestas concisas (2-3 oraciones máximo). Haz UNA pregunta de seguimiento a la vez. Usa un tono amigable y casual.

    IMPORTANTE: Cuando el usuario comparta feedback concreto, USA la herramienta save_feedback para guardarlo. Después de guardar, confirma brevemente que lo anotaste y sigue preguntando.

    SIEMPRE responde en español.
    """
    // swiftlint:enable line_length

    private var feedbackTool: MessageParameter.Tool {
        MessageParameter.Tool(
            name: "save_feedback",
            description: "Guarda feedback del usuario en la base de datos",
            inputSchema: .init(
                type: .object,
                properties: [
                    "category": .init(
                        type: .string,
                        description: "Categoría: like, dislike, feature_request, bug, general",
                        enumValues: ["like", "dislike", "feature_request", "bug", "general"]
                    ),
                    "summary": .init(
                        type: .string,
                        description: "Resumen corto del feedback"
                    ),
                    "details": .init(
                        type: .string,
                        description: "Detalles adicionales"
                    ),
                    "screen": .init(
                        type: .string,
                        description: "Pantalla de la app"
                    )
                ],
                required: ["category", "summary"]
            )
        )
    }

    var canSend: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isStreaming
    }

    init() {
        messages.append(FeedbackMessage(
            text: "¡Hola! 👋 Estoy aquí para escuchar sobre tu experiencia con DateNight. ¿Qué te parece la app — algo que te encante, que no te guste, o que desearías que fuera diferente?",
            isUser: false
        ))
    }

    func sendMessage() async {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        messages.append(FeedbackMessage(text: text, isUser: true))
        inputText = ""
        isStreaming = true

        guard claudeService.isConfigured else {
            messages.append(FeedbackMessage(
                text: "¡Gracias por compartir! No estoy conectado ahora (se necesita clave API). ¿Qué más quieres compartir?",
                isUser: false
            ))
            isStreaming = false
            return
        }

        do {
            let response = try await sendWithTools()
            if !response.isEmpty {
                messages.append(FeedbackMessage(text: response, isUser: false))
            }
        } catch {
            Logger.error("Feedback chat error", data: ["error": error.localizedDescription])
            messages.append(FeedbackMessage(
                text: "¡Ups, tuve un problemita! ¿Podrías intentar de nuevo?",
                isUser: false
            ))
        }

        isStreaming = false
    }

    // MARK: - Tool Use

    private func sendWithTools() async throws -> String {
        guard let service = makeService() else {
            throw ClaudeError.notConfigured
        }

        // Build API messages from conversation
        var apiMessages: [MessageParameter.Message] = []
        for msg in messages {
            let role: MessageParameter.Message.Role = msg.isUser ? .user : .assistant
            apiMessages.append(.init(role: role, content: .text(msg.text)))
        }

        var finalText = ""

        // Tool use loop
        for _ in 0 ..< 3 {
            let params = MessageParameter(
                model: .other("claude-sonnet-4-20250514"),
                messages: apiMessages,
                maxTokens: 400,
                system: .text(systemPrompt),
                tools: [feedbackTool]
            )

            let response = try await service.createMessage(params)

            var hasToolUse = false

            for block in response.content {
                switch block {
                case let .text(text):
                    finalText = text
                case let .toolUse(toolUse):
                    hasToolUse = true
                    let result = await saveFeedback(toolUse: toolUse)

                    // Add assistant message with tool use, then tool result
                    apiMessages.append(.init(
                        role: .assistant,
                        content: .list([
                            .toolUse(toolUse.id, toolUse.name, toolUse.input)
                        ])
                    ))
                    apiMessages.append(.init(
                        role: .user,
                        content: .list([
                            .toolResult(toolUse.id, result)
                        ])
                    ))
                }
            }

            if !hasToolUse {
                break
            }
        }

        return finalText
    }

    private func saveFeedback(toolUse: MessageResponse.Content.ToolUse) async -> String {
        // Extract from the input dictionary
        let input = toolUse.input
        let category = (input["category"] as? String) ?? "general"
        let summary = (input["summary"] as? String) ?? ""
        let details = (input["details"] as? String) ?? ""
        let screen = (input["screen"] as? String) ?? ""

        do {
            let client = SupabaseService.shared.client
            try await client.from("feedback").insert([
                "category": category,
                "summary": summary,
                "details": details,
                "screen": screen
            ]).execute()

            savedFeedbackCount += 1
            Logger.info("Feedback saved", data: ["category": category, "summary": summary])
            return "Guardado: \(summary)"
        } catch {
            Logger.error("Save failed", data: ["error": error.localizedDescription])
            return "Error: \(error.localizedDescription)"
        }
    }

    private func makeService() -> AnthropicService? {
        guard claudeService.isConfigured else { return nil }
        if Configuration.isDirectAPIConfigured {
            return AnthropicServiceFactory.service(apiKey: Configuration.anthropicAPIKey, betaHeaders: nil)
        }
        if Configuration.isAIProxyConfigured {
            return AnthropicServiceFactory.service(
                aiproxyPartialKey: Configuration.aiproxyPartialKey,
                aiproxyServiceURL: Configuration.aiproxyServiceURL,
                betaHeaders: nil
            )
        }
        return nil
    }
}
