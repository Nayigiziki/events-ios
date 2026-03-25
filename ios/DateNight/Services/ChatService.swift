import Foundation
import Supabase

@MainActor
final class ChatService {
    private var client: SupabaseClient { SupabaseService.shared.client }
    private var realtimeChannel: RealtimeChannelV2?

    func fetchConversations() async throws -> [Conversation] {
        let userId = try await client.auth.session.user.id

        let conversations: [Conversation] = try await client.from("conversations")
            .select("*, participants:conversation_participants(user:profiles(*)), last_message:messages(*)")
            .eq("conversation_participants.user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value

        return conversations
    }

    func fetchMessages(conversationId: UUID) async throws -> [Message] {
        let messages: [Message] = try await client.from("messages")
            .select()
            .eq("conversation_id", value: conversationId.uuidString)
            .order("created_at", ascending: true)
            .execute()
            .value

        return messages
    }

    func sendMessage(conversationId: UUID, content: String, messageType: MessageType = .text) async throws {
        let userId = try await client.auth.session.user.id

        try await client.from("messages")
            .insert([
                "conversation_id": conversationId.uuidString,
                "sender_id": userId.uuidString,
                "content": content,
                "message_type": messageType.rawValue
            ])
            .execute()
    }

    func subscribeToMessages(conversationId: UUID, callback: @escaping (Message) -> Void) async {
        let channel = client.realtimeV2.channel("messages:\(conversationId.uuidString)")

        let insertions = channel.postgresChange(
            InsertAction.self,
            table: "messages",
            filter: "conversation_id=eq.\(conversationId.uuidString)"
        )

        Task {
            for await insertion in insertions {
                if let message = try? insertion.decodeRecord(as: Message.self, decoder: JSONDecoder()) {
                    await MainActor.run {
                        callback(message)
                    }
                }
            }
        }

        await channel.subscribe()
        realtimeChannel = channel
    }

    func unsubscribe() async {
        if let channel = realtimeChannel {
            await channel.unsubscribe()
            realtimeChannel = nil
        }
    }
}
