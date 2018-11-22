import Foundation
import UIKit

/// Implementation of the AbstractLog.
public class SimpleLog: AbstractLog {
    
    public var printer: LogPrinter
    public var blackList: String
    
    /// Initialize this log implementation.
    public init(settings: LogSettings) {
        self.printer = settings.printer
        self.blackList = settings.blackList
        super.init()
        self.level = settings.level
        print("🐸 Log initialized with \(settings)")
    }
    
    /// Capture detailed information useful during debugging.
    public override func verbose(_ message: @autoclosure () -> String, _ file: Any? = #file, _ function: String = #function, _ line: UInt = #line) {
        writeIfLoggable(message, file, function, line, for: .trace)
    }
    
    /// Capture information useful during development.
    public override func debug(_ message: @autoclosure () -> String, _ file: Any? = #file, _ function: String = #function, _ line: UInt = #line) {
        writeIfLoggable(message, file, function, line, for: .debug)
    }
    
    /// Capture application events.
    public override func info(_ message: @autoclosure () -> String, _ file: Any? = #file, _ function: String = #function, _ line: UInt = #line) {
        writeIfLoggable(message, file, function, line, for: .info)
    }
    
    /// Capture potentially problematic events.
    public override func warning(_ message: @autoclosure () -> String, _ file: Any? = #file, _ function: String = #function, _ line: UInt = #line) {
        writeIfLoggable(message, file, function, line, for: .warn)
    }
    
    /// Capture application errors.
    public override func error(_ message: @autoclosure () -> String, _ file: Any? = #file, _ function: String = #function, _ line: UInt = #line) {
        writeIfLoggable(message, file, function, line, for: .error)
    }
    
    private func writeIfLoggable(_ message: @autoclosure () -> String, _ file: Any?, _ function: String, _ line: UInt, for level: LogLevel) {
        if isLoggable(level: level) {
            write(message, file, function, line, level: level)
        }
    }
    private func write(_ msg: @autoclosure () -> String, _ file: Any? = #file, _ function: String = #function, _ line: UInt = #line, level: LogLevel) {
        let message = LogMessage(blackList: blackList, file: file, function: function, line: line, level: level, message: msg())
        printer.write(message: message)
    }
    private func isLoggable(level: LogLevel) -> Bool {
        let log = self.level <= level
        return log
    }
    
    // Change the log level using a deeplink.
    public func update(withDeeplinkParams params: [String: String]?) {
        guard let validParams: [String: String] = params else {
            return
        }
        verbose("Trying update Logger with \(validParams)")
        if let levelString: String = validParams["severityLevel"] {
            
            if let levelInt = Int(levelString),
                let newLevel = LogLevel(rawValue: levelInt) {
                level = newLevel
            } else {
                error("We failed to update severity level with \(levelString)")
            }
        }
    }
}
