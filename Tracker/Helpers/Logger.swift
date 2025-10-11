import Foundation

enum Emoji: String {
    case info = "👀 INFO"
    case success = "✅ SUCCESS"
    case error = "❌ ERROR"
    case debug = "🪲 DEBUG"
    case warning = "⚠️ WARNING"
}

struct Logger {
    
    // MARK: - Public Static Methods
    static func log(_ message: String,
                    emoji: Emoji = .info,
                    file: String = #fileID,
                    function: String = #function,
                    line: Int = #line,
                    column: Int? = #column) {
        
        let className = file.components(separatedBy: "/").last?.components(separatedBy: ".").first ?? "Unknown"
        let timestamp = Logger.timestamp()
        let columnString: String
        if let column = column {
            columnString = ";\(column)"
        } else {
            columnString = ""
        }
        print("[\(timestamp)] [\(emoji.rawValue)] [\(className).\(function):\(line)\(columnString)] – \(message)")
    }
    
    static func log(_ message: String,
                    emoji: Emoji = .info,
                    file: String = #fileID,
                    function: String = #function,
                    line: Int = #line) {
        log(message, emoji: emoji, file: file, function: function, line: line, column: nil)
    }
    
    static func info(_ message: String,
                     file: String = #fileID,
                     function: String = #function,
                     line: Int = #line) {
        log(message, emoji: .info, file: file, function: function, line: line, column: nil)
    }
    
    static func debug(_ message: String,
                      file: String = #fileID,
                      function: String = #function,
                      line: Int = #line) {
        log(message, emoji: .debug, file: file, function: function, line: line, column: nil)
    }
    
    static func success(_ message: String,
                        file: String = #fileID,
                        function: String = #function,
                        line: Int = #line) {
        log(message, emoji: .success, file: file, function: function, line: line, column: nil)
    }
    
    static func error(_ message: String,
                      file: String = #fileID,
                      function: String = #function,
                      line: Int = #line) {
        log(message, emoji: .error, file: file, function: function, line: line, column: nil)
    }
    
    static func warning(_ message: String,
                      file: String = #fileID,
                      function: String = #function,
                      line: Int = #line) {
        log(message, emoji: .warning, file: file, function: function, line: line, column: nil)
    }
    
    // MARK: - Private Methods
    private static func timestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: Date())
    }
}
