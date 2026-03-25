import Foundation

/// App configuration loaded from Info.plist or environment
enum Configuration {
    // MARK: - AIProxy Configuration (for SwiftAnthropic)

    /// AIProxy partial key - loaded from Info.plist
    /// Set via xcconfig: AIPROXY_PARTIAL_KEY = your_key_here
    static var aiproxyPartialKey: String {
        Bundle.main.object(forInfoDictionaryKey: "AIPROXY_PARTIAL_KEY") as? String
            ?? ProcessInfo.processInfo.environment["AIPROXY_PARTIAL_KEY"]
            ?? ""
    }

    /// AIProxy service URL - loaded from Info.plist
    /// Set via xcconfig: AIPROXY_SERVICE_URL = https://your-service.aiproxy.pro
    static var aiproxyServiceURL: String {
        Bundle.main.object(forInfoDictionaryKey: "AIPROXY_SERVICE_URL") as? String
            ?? ProcessInfo.processInfo.environment["AIPROXY_SERVICE_URL"]
            ?? ""
    }

    /// Direct Anthropic API key (for development only - NOT recommended for production)
    /// Set via xcconfig/Info.plist or environment variable: ANTHROPIC_API_KEY
    static var anthropicAPIKey: String {
        Bundle.main.object(forInfoDictionaryKey: "ANTHROPIC_API_KEY") as? String
            ?? ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"]
            ?? ""
    }

    /// Check if AIProxy is configured
    static var isAIProxyConfigured: Bool {
        !aiproxyPartialKey.isEmpty && !aiproxyServiceURL.isEmpty
    }

    /// Check if direct API key is available (development fallback)
    static var isDirectAPIConfigured: Bool {
        !anthropicAPIKey.isEmpty
    }

    /// Check if any Claude configuration is available
    static var isClaudeConfigured: Bool {
        isAIProxyConfigured || isDirectAPIConfigured
    }
}
