import SwiftData
import SwiftUI

struct ChatView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var claudeService: ClaudeService
    @State private var viewModel: ChatViewModel?
    @State private var showingClearConfirmation = false

    var body: some View {
        Group {
            if let viewModel {
                ChatContentView(viewModel: viewModel, showingClearConfirmation: $showingClearConfirmation)
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Chat")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingClearConfirmation = true
                } label: {
                    Image(systemName: "trash")
                }
                .disabled(viewModel == nil)
            }
        }
        .onAppear {
            if viewModel == nil {
                let vm = ChatViewModel(claudeService: claudeService, modelContext: modelContext)
                vm.loadMessages()
                viewModel = vm
            }
        }
    }
}

struct ChatContentView: View {
    @ObservedObject var viewModel: ChatViewModel
    @Binding var showingClearConfirmation: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Messages list
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages.count) { _, _ in
                    if let last = viewModel.messages.last {
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }

            Divider()

            // Input area
            HStack(alignment: .bottom, spacing: 12) {
                TextField("Message", text: $viewModel.input, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1 ... 6)
                    .disabled(viewModel.isStreaming)

                Button {
                    Task {
                        await viewModel.sendMessage()
                    }
                } label: {
                    Image(systemName: viewModel.isStreaming ? "stop.circle.fill" : "arrow.up.circle.fill")
                        .font(.title2)
                }
                .disabled(viewModel.input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !viewModel
                    .isStreaming)
            }
            .padding()
        }
        .confirmationDialog("Clear Chat History", isPresented: $showingClearConfirmation) {
            Button("Clear All", role: .destructive) {
                viewModel.clearHistory()
            }
        } message: {
            Text("This will delete all messages in this conversation.")
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
    }
}

struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.role == "user" {
                Spacer()
            }

            VStack(alignment: message.role == "user" ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(12)
                    .background(message.role == "user" ? Color.blue : Color.gray.opacity(0.2))
                    .foregroundStyle(message.role == "user" ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            if message.role == "assistant" {
                Spacer()
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChatView()
            .environmentObject(ClaudeService())
            .modelContainer(for: ChatMessage.self, inMemory: true)
    }
}
