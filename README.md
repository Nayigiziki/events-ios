# DateNight

DateNight is an iOS app powered by Claude AI.

## Tech Stack

- **iOS 17.0+** with SwiftUI
- **Claude AI** via [SwiftAnthropic](https://github.com/jamesrochabrun/SwiftAnthropic)
- **SwiftData** for local storage
- **Xcode 15.0+**

## Prerequisites

- Xcode 15.0+
- Ruby (for Fastlane)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen): `brew install xcodegen`
- [Fastlane](https://fastlane.tools): `gem install fastlane`
- [Pre-commit](https://pre-commit.com): `brew install pre-commit`

## Setup

1. **Configure API Key**

   Add your Anthropic API key to `ios/Secrets.xcconfig`:
   ```
   ANTHROPIC_API_KEY = sk-ant-api03-...
   ```

   Get your key at: https://console.anthropic.com/settings/keys

2. **Open the Project**

   ```bash
   cd ios
   open DateNight.xcodeproj
   ```

3. **Build and Run**

   Press ⌘R in Xcode or:
   ```bash
   cd ios
   fastlane build
   ```

## Project Structure

```
datenight/
├── ios/
│   ├── project.yml                    # XcodeGen configuration
│   ├── DateNight/
│   │   ├── App/
│   │   │   ├── DateNightApp.swift
│   │   │   └── ContentView.swift
│   │   ├── Services/
│   │   │   ├── ClaudeService.swift   # SwiftAnthropic wrapper
│   │   │   ├── Configuration.swift   # API key management
│   │   │   └── Logger.swift
│   │   ├── Models/                   # SwiftData models
│   │   └── Features/
│   │       ├── Chat/              # Example chat interface
│   │       └── Settings/
│   ├── fastlane/
│   │   └── Fastfile                  # Build & deploy automation
│   └── scripts/
│       └── deploy-testflight.sh      # TestFlight deployment
└── README.md
```

## Development

### Running Tests

```bash
cd ios
fastlane test
```

### Code Quality

```bash
# Lint
cd ios
fastlane lint

# Auto-format
swiftformat .
```

### Regenerating Xcode Project

After modifying `project.yml`:

```bash
cd ios
xcodegen generate
```

## Configuration

### Bundle Identifier
`com.tron.datenight`

### Development Team
`L6JNH6A9TS`

Update these in `ios/project.yml` as needed.

### API Authentication

**Direct API (Development):**
```
ANTHROPIC_API_KEY = sk-ant-...
```

**AIProxy (Production):**
```
AIPROXY_PARTIAL_KEY = your-partial-key
AIPROXY_SERVICE_URL = https://your-service.aiproxy.pro
```

See [AIProxy documentation](https://aiproxy.pro/docs) for setup.

## Deployment

### TestFlight

1. **Configure App Store Connect API Key**

   Download from App Store Connect and place at:
   ```
   ~/.private_keys/AuthKey_XXXXXXXXXX.p8
   ```

2. **Update Fastfile**

   Edit `ios/fastlane/Fastfile` with your API key details.

3. **Deploy**

   ```bash
   cd ios
   ./scripts/deploy-testflight.sh
   ```

See `docs/deployment.md` for detailed instructions.

## Customization

### Renaming the App

1. Edit `ios/project.yml`:
   ```yaml
   name: NewName
   PRODUCT_BUNDLE_IDENTIFIER: com.tron.newname
   ```

2. Regenerate:
   ```bash
   cd ios && xcodegen generate
   ```

### Adding Features

Create new features in `DateNight/Features/`:

```swift
import SwiftUI

struct MyFeatureView: View {
    @EnvironmentObject var claudeService: ClaudeService

    var body: some View {
        // Your UI here
    }
}
```

Use ClaudeService for AI integration:

```swift
// Streaming chat
try await claudeService.streamChat(
    message: "Hello, Claude!",
    onToken: { token in
        // Handle each streamed token
        print(token)
    }
)

// Simple request
let response = try await claudeService.sendMessage("What is Swift?")
```

### SwiftData Models

```swift
import SwiftData

@Model
final class MyModel {
    var id: UUID
    var name: String

    init(name: String) {
        self.id = UUID()
        self.name = name
    }
}
```

Register in `DateNightApp.swift`:

```swift
.modelContainer(for: [MyModel.self])
```

## Example Chat Feature

The included chat feature demonstrates:

- **Streaming responses** from Claude
- **SwiftData persistence** for message history
- **Conversation context** management
- **Error handling** and user feedback
- **Clean architecture** with ViewModel pattern

Code locations:
- View: `DateNight/Features/Chat/ChatView.swift`
- ViewModel: `DateNight/Features/Chat/ChatViewModel.swift`
- Model: `DateNight/Models/ChatMessage.swift`

## Troubleshooting

### "Cannot find module 'SwiftAnthropic'"

Regenerate the Xcode project:
```bash
cd ios && xcodegen generate
```

### "Claude not configured"

Add your API key to `ios/Secrets.xcconfig`.

### Build errors after git pull

Clean and rebuild:
```bash
cd ios
xcodegen generate
# Then clean build folder in Xcode (⇧⌘K)
```

## License

MIT

---

**Built from** [template_swift_app](https://github.com/tron/template_swift_app)
**Author:** Your Name
