import SwiftUI

struct FeedbackChatView: View {
    @StateObject private var viewModel = FeedbackChatViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Header
            header

            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: DNSpace.md) {
                        ForEach(viewModel.messages) { message in
                            FeedbackBubble(message: message)
                                .id(message.id)
                        }

                        if viewModel.isStreaming {
                            HStack(spacing: DNSpace.sm) {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Thinking...")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.dnTextTertiary)
                                Spacer()
                            }
                            .padding(.horizontal, DNSpace.lg)
                            .id("loading")
                        }
                    }
                    .padding(.vertical, DNSpace.md)
                }
                .onChange(of: viewModel.messages.count) { _ in
                    withAnimation {
                        proxy.scrollTo(viewModel.messages.last?.id ?? "loading", anchor: .bottom)
                    }
                }
                .onChange(of: viewModel.streamingText) { _ in
                    withAnimation {
                        proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                    }
                }
            }

            // Input bar
            inputBar
        }
        .background(Color.dnBackground.ignoresSafeArea())
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: DNSpace.md) {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.dnTextPrimary)
                    .frame(width: 36, height: 36)
                    .dnNeuRaised(intensity: .light, cornerRadius: DNRadius.full)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text("DateNight Feedback")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.dnTextPrimary)
                Text("Powered by Claude")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.dnPrimary)
            }

            Spacer()

            Image(systemName: "sparkles")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.dnPrimary)
                .frame(width: 36, height: 36)
                .dnNeuRaised(intensity: .light, cornerRadius: DNRadius.full)
        }
        .padding(.horizontal, DNSpace.lg)
        .padding(.vertical, DNSpace.md)
        .dnNeuRaised(intensity: .medium, cornerRadius: 0)
    }

    // MARK: - Input Bar

    private var inputBar: some View {
        HStack(spacing: DNSpace.md) {
            TextField("Share your feedback...", text: $viewModel.inputText, axis: .vertical)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.dnTextPrimary)
                .lineLimit(1 ... 4)
                .padding(.horizontal, DNSpace.lg)
                .padding(.vertical, DNSpace.md)
                .frame(minHeight: 48)
                .dnNeuPressed(intensity: .light, cornerRadius: DNRadius.md)

            Button {
                Task { await viewModel.sendMessage() }
            } label: {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(viewModel.canSend ? .white : .dnTextTertiary)
                    .frame(width: 48, height: 48)
                    .background(
                        Circle()
                            .fill(viewModel.canSend ? Color.dnPrimary : Color.dnBackground)
                    )
                    .dnNeuRaised(intensity: .light, cornerRadius: DNRadius.full)
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.canSend)
        }
        .padding(.horizontal, DNSpace.lg)
        .padding(.vertical, DNSpace.md)
        .dnNeuRaised(intensity: .medium, cornerRadius: 0)
    }
}

// MARK: - Message Bubble

struct FeedbackBubble: View {
    let message: FeedbackMessage

    var body: some View {
        HStack {
            if message.isUser { Spacer(minLength: 60) }

            VStack(alignment: message.isUser ? .trailing : .leading, spacing: DNSpace.xs) {
                if !message.isUser {
                    HStack(spacing: DNSpace.xs) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.dnPrimary)
                        Text("Claude")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.dnPrimary)
                    }
                }

                Text(message.text)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(message.isUser ? .white : .dnTextPrimary)
                    .padding(.horizontal, DNSpace.lg)
                    .padding(.vertical, DNSpace.md)
                    .background(
                        RoundedRectangle(cornerRadius: DNRadius.md, style: .continuous)
                            .fill(message.isUser ? Color.dnPrimary : Color.dnBackground)
                    )
                    .if(!message.isUser) { view in
                        view.dnNeuRaised(intensity: .light, cornerRadius: DNRadius.md)
                    }
            }

            if !message.isUser { Spacer(minLength: 60) }
        }
        .padding(.horizontal, DNSpace.lg)
    }
}

#Preview {
    FeedbackChatView()
}
