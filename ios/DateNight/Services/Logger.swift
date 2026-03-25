import Foundation
import os.log

/// File-based logger for DateNight
final class Logger {
    static let shared = Logger()

    private let fileURL: URL
    private let queue = DispatchQueue(label: "com.tron.datenight.logger", qos: .utility)
    private let osLog = OSLog(subsystem: "com.tron.datenight", category: "general")

    enum Level: String {
        case debug = "DEBUG"
        case info = "INFO"
        case warn = "WARN"
        case error = "ERROR"
    }

    /// Check if running in simulator
    private static var isSimulator: Bool {
        #if targetEnvironment(simulator)
            return true
        #else
            return false
        #endif
    }

    private init() {
        // Use Documents directory for logs
        let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let logsDir = documentsDir.appendingPathComponent("logs")

        // Create directory if needed
        try? FileManager.default.createDirectory(at: logsDir, withIntermediateDirectories: true)

        // Log file path
        self.fileURL = logsDir.appendingPathComponent("app.log")
    }

    private func log(
        _ level: Level,
        _ message: String,
        data: [String: Any]? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let fileName = (file as NSString).lastPathComponent
        let dataStr = data.map { " | \(formatData($0))" } ?? ""
        let logLine = "[\(timestamp)] [\(level.rawValue)] [\(fileName):\(line)] \(message)\(dataStr)\n"

        // Console output
        switch level {
        case .debug:
            os_log(.debug, log: osLog, "%{public}@", logLine)
        case .info:
            os_log(.info, log: osLog, "%{public}@", logLine)
        case .warn:
            os_log(.default, log: osLog, "%{public}@", logLine)
        case .error:
            os_log(.error, log: osLog, "%{public}@", logLine)
        }

        // Also print to console for Xcode
        print(logLine, terminator: "")

        // Write to file asynchronously
        queue.async { [weak self] in
            self?.writeToFile(logLine)
        }
    }

    private func formatData(_ data: [String: Any]) -> String {
        let pairs = data.map { "\($0.key)=\($0.value)" }
        return pairs.joined(separator: ", ")
    }

    private func writeToFile(_ line: String) {
        guard let data = line.data(using: .utf8) else { return }

        if FileManager.default.fileExists(atPath: fileURL.path) {
            // Append to existing file
            if let fileHandle = try? FileHandle(forWritingTo: fileURL) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            }
        } else {
            // Create new file
            try? data.write(to: fileURL)
        }
    }

    // MARK: - Public API

    static func debug(
        _ message: String,
        data: [String: Any]? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        shared.log(.debug, message, data: data, file: file, function: function, line: line)
    }

    static func info(
        _ message: String,
        data: [String: Any]? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        shared.log(.info, message, data: data, file: file, function: function, line: line)
    }

    static func warning(
        _ message: String,
        data: [String: Any]? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        shared.log(.warn, message, data: data, file: file, function: function, line: line)
    }

    static func error(
        _ message: String,
        data: [String: Any]? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        shared.log(.error, message, data: data, file: file, function: function, line: line)
    }

    /// Get the log file path (useful for sharing/debugging)
    static var logFilePath: String {
        shared.fileURL.path
    }

    /// Clear the log file
    static func clearLogs() {
        try? FileManager.default.removeItem(at: shared.fileURL)
        info("Logs cleared")
    }

    /// Get recent log contents
    static func getRecentLogs(lines: Int = 100) -> String {
        guard let content = try? String(contentsOf: shared.fileURL, encoding: .utf8) else {
            return "No logs available"
        }
        let allLines = content.components(separatedBy: "\n")
        let recentLines = allLines.suffix(lines)
        return recentLines.joined(separator: "\n")
    }
}
