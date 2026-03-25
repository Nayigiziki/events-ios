# Architecture Guide

## Overview

DateNight follows a clean, feature-based architecture that prioritizes:

- **Simplicity** - Minimal abstraction layers
- **Maintainability** - Clear separation of concerns
- **Testability** - Dependency injection throughout
- **Scalability** - Easy to add new features

## Architecture Layers

```
┌─────────────────────────────────────┐
│           SwiftUI Views             │  ← User Interface
├─────────────────────────────────────┤
│          View Models                │  ← Presentation Logic
├─────────────────────────────────────┤
│       Services (Business Logic)     │  ← Claude, Configuration, Logger
├─────────────────────────────────────┤
│      Models (SwiftData)             │  ← Data Layer
└─────────────────────────────────────┘
```

## Directory Structure

```
DateNight/
├── App/                    # Application entry point
│   ├── DateNightApp.swift      # @main, dependency setup
│   └── ContentView.swift   # Root view
│
├── Features/               # Feature modules (vertical slices)
│   ├── Chat/              # Chat feature
│   │   ├── ChatView.swift
│   │   └── ChatViewModel.swift
│   └── Settings/
│       └── SettingsView.swift
│
├── Services/              # Shared business logic
│   ├── ClaudeService.swift     # Claude AI integration
│   ├── Configuration.swift     # App configuration
│   └── Logger.swift            # Logging utility
│
├── Models/                # Data models
│   └── ChatMessage.swift  # SwiftData model
│
└── Resources/             # Assets, configs
    └── Assets.xcassets
```

## Feature-Based Organization

Each feature is a **vertical slice** containing all related code:

```
Features/MyFeature/
├── MyFeatureView.swift        # UI
├── MyFeatureViewModel.swift   # Logic
└── MyFeatureModels.swift      # Feature-specific models (optional)
```

Benefits:
- Easy to find all code for a feature
- Clear feature boundaries
- Simple to add/remove features
- Facilitates modularization later

## Service Layer

### ClaudeService

Wraps SwiftAnthropic SDK for AI integration.

**Responsibilities:**
- Manage API authentication (direct or AIProxy)
- Stream chat responses
- Handle conversation context
- Error management

**Usage:**
```swift
@EnvironmentObject var claudeService: ClaudeService

// Streaming
try await claudeService.streamChat(
    message: "Hello!",
    conversationHistory: history,
    onToken: { token in
        // Handle streaming tokens
    }
)

// Non-streaming
let response = try await claudeService.sendMessage("Quick question")
```

### Configuration

Centralized app configuration.

**Responsibilities:**
- Load API keys from xcconfig/environment
- Detect authentication method (AIProxy vs direct)
- Provide configuration status

### Logger

File-based logging for debugging.

**Responsibilities:**
- Log to Documents directory
- Categorize by level (debug, info, warning, error)
- Support log sharing for debugging

**Usage:**
```swift
Logger.info("User action", data: ["action": "tap", "screen": "home"])
Logger.error("API failed", data: ["error": error.localizedDescription])
```

## Data Layer (SwiftData)

### Models

SwiftData models use the `@Model` macro:

```swift
import SwiftData

@Model
final class ChatMessage {
    var id: UUID
    var role: String
    var content: String
    var timestamp: Date

    init(role: String, content: String) {
        self.id = UUID()
        self.role = role
        self.content = content
        self.timestamp = Date()
    }
}
```

### Model Container

Registered in `DateNightApp.swift`:

```swift
WindowGroup {
    ContentView()
}
.modelContainer(for: [ChatMessage.self])
```

### Querying Data

```swift
@Environment(\.modelContext) private var modelContext

func loadMessages() {
    let descriptor = FetchDescriptor<ChatMessage>(
        sortBy: [SortDescriptor(\.timestamp)]
    )
    let messages = try? modelContext.fetch(descriptor)
}
```

## Dependency Injection

### Environment Objects

Services are injected via SwiftUI environment:

```swift
// In App
@StateObject private var claudeService = ClaudeService()

WindowGroup {
    ContentView()
        .environmentObject(claudeService)
}

// In Views
@EnvironmentObject var claudeService: ClaudeService
```

### Model Context

SwiftData context is injected automatically:

```swift
@Environment(\.modelContext) private var modelContext
```

## State Management

### View State

Use `@State` for local view state:

```swift
@State private var isLoading = false
@State private var showError = false
```

### Shared State

Use `@StateObject` + `@EnvironmentObject` for shared state:

```swift
// Create once
@StateObject private var claudeService = ClaudeService()

// Inject
.environmentObject(claudeService)

// Use anywhere
@EnvironmentObject var claudeService: ClaudeService
```

### Persistent State

Use SwiftData for persistent state:

```swift
@Environment(\.modelContext) private var modelContext

func saveMessage(_ message: ChatMessage) {
    modelContext.insert(message)
    try? modelContext.save()
}
```

## Error Handling

### Service Layer

Services throw errors that views handle:

```swift
do {
    let response = try await claudeService.sendMessage("Hello")
} catch {
    Logger.error("Request failed", data: ["error": error.localizedDescription])
    errorMessage = error.localizedDescription
}
```

### User-Facing Errors

Use SwiftUI alerts:

```swift
@State private var errorMessage: String?

.alert("Error", isPresented: .constant(errorMessage != nil)) {
    Button("OK") { errorMessage = nil }
} message: {
    if let error = errorMessage {
        Text(error)
    }
}
```

## Testing Strategy

### Unit Tests

Test view models and services:

```swift
@Test
func testClaudeService() async throws {
    let service = ClaudeService(preferDirectAPI: true)
    let response = try await service.sendMessage("Hello")
    #expect(!response.isEmpty)
}
```

### UI Tests

Test user flows:

```swift
@Test
func testChatFlow() {
    let app = XCUIApplication()
    app.launch()
    // Test interactions
}
```

## Best Practices

1. **Keep views simple** - Move logic to ViewModels
2. **Use async/await** - Modern concurrency over callbacks
3. **Inject dependencies** - via EnvironmentObject
4. **Log important events** - Use Logger for debugging
5. **Handle errors gracefully** - Show user-friendly messages
6. **Keep features isolated** - Minimize cross-feature dependencies
7. **Use SwiftData** - for local persistence
8. **Follow Swift naming conventions** - camelCase, descriptive names

## Adding New Features

1. Create feature directory in `Features/`
2. Add View and ViewModel files
3. Inject required services via `@EnvironmentObject`
4. Add SwiftData models if needed
5. Register models in App.swift
6. Add navigation link from ContentView

Example:

```swift
// 1. Create Files/Todos/TodosView.swift
struct TodosView: View {
    @EnvironmentObject var claudeService: ClaudeService
    // ...
}

// 2. Register in ContentView
NavigationLink("Todos") {
    TodosView()
}
```

## Resources

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [SwiftData Guide](https://developer.apple.com/documentation/swiftdata)
- [SwiftAnthropic](https://github.com/jamesrochabrun/SwiftAnthropic)
- [Anthropic API Docs](https://docs.anthropic.com/)
