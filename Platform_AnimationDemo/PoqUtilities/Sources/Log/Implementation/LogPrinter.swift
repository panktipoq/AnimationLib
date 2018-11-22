import Foundation
import os.log

/// Ouputs where the log is sent to.
public enum LogPrinter: Int {
    
    /// NSLog
    case nslog = 0
    
    /// OSLog
    case oslog = 1
    
    /// Standard output. Usually the Xcode console pane.
    case stdout = 2
    
    private static let serialQueue = DispatchQueue(label: "LogPrinter", qos: DispatchQoS.background )
    
    private static let osLogger: OSLog? = {
        return OSLog(subsystem: Bundle.main.bundleIdentifier ?? "", category: "PoqLogger")
    }()
    
    /// Send a log message to the logger represented by the current instance.
    func write(message: LogMessage) {
        let blackList = message.blackList
        switch self {
        case .nslog:
            let log = LogPrinter.applyFormat(format: format(blackList: blackList), message: message)
            if !log.isEmpty {
                LogPrinter.serialQueue.async {
                    NSLog(log)
                }
            }
        case .oslog:
            let log = LogPrinter.applyFormat(format: format(blackList: blackList), message: message)
            if log.count > 0 {
                
                if !log.isEmpty {
                    os_log("%@", log: LogPrinter.osLogger ?? OSLog.default, type: osLogType(for: message.level), log)
                }
            }
        case .stdout:
            let log = LogPrinter.applyFormat(format: format(blackList: message.blackList), message: message)
            if !log.isEmpty {
                LogPrinter.serialQueue.async {
                    print(log)
                }
            }
        }
    }
    
    private func osLogType(for level: LogLevel) -> OSLogType {
        switch level {
        case .trace:
            return .debug
        case .info:
            return .info
        case .debug:
            return .debug
        case .warn:
            return OSLogType.default
        case .error:
            return .error
        case .none:
            return .fault
        }
    }
    
    private func format(blackList: String) -> LogFormat {
        switch self {
        case .nslog:
            return .default
        case .oslog:
            return .simple(blackList: blackList)
        case .stdout:
            return .colored(blackList: blackList)
        }
    }
    
    private static func applyFormat(format: LogFormat, message: LogMessage) -> String {
        return format.tokens().reduce("") { (result, token) -> String in
            return token.transform(string: result, with: message)
        }
    }
}

extension LogPrinter: CustomStringConvertible {
    
    /// Human-readable description of this printer.
    public var description: String {
        switch self {
        case .nslog:
            return "nslog"
        case .oslog:
            return "oslog"
        case .stdout:
            return "stdout"
        }
    }
}
