import Foundation

/**
 Global settings for the log.
 
 You can change them for your computer only by setting UserDefaults.
 For instance, to change the log printer to 'print' and set a blacklist, pause the app and run the following in the LLDB console, then relaunch the app.
 
 e @import Foundation
 e [NSUserDefaults.standardUserDefaults setInteger:2 forKey: @"LogPrinter"]
 e [NSUserDefaults.standardUserDefaults setObject: @"(AppSettings|objc|AppConfiguration|ImageInjectionResolver|NibInjectionResolver)" forKey: @"LogBlackList"]
 
 */
public struct LogSettings: CustomStringConvertible {
    
    private static let levelKey = "LogLevel"
    private static let printerKey = "LogPrinter"
    private static let blackListKey = "LogBlacklist"
    
    private static var store: UserDefaults {
        return UserDefaults.standard
    }
    
    /**
     Initialize with the given category.
     
     - Parameter level: Threshold level. Logs below this level will be ignored.
     - Parameter printer: Ouput where the log is sent to.
     - Parameter blackList: Regular expression that discards log messages on succesful match.
     */
    public init(level: LogLevel? = nil, printer: LogPrinter? = nil, blackList: String? = nil) {
        
        if let level = level {
            self.level = level
        }
        
        if let printer = printer {
            self.printer = printer
        }
        
        if let blacklistUnwrapped = blackList {
            self.blackList = blacklistUnwrapped
        }
    }
    
    /// Threshold level. Logs below this level will be ignored.
    var level: LogLevel {
        get {
            guard LogSettings.isDebuggerAttached() else {
                return .none
            }
            guard LogSettings.store.object(forKey: LogSettings.levelKey) != nil else {
                return .warn
            }
            guard let level = LogLevel(rawValue: LogSettings.store.integer(forKey: LogSettings.levelKey)) else {
                return .warn
            }
            return level
        }
        set {
            LogSettings.store.set(newValue, forKey: LogSettings.levelKey)
        }
    }
    
    // Log printer (print, nslog, or oslog).
    var printer: LogPrinter {
        get {
            guard LogSettings.store.object(forKey: LogSettings.printerKey) != nil else {
                return .oslog
            }
            guard let printer = LogPrinter(rawValue: LogSettings.store.integer(forKey: LogSettings.printerKey)) else {
                return .oslog
            }
            return printer
        }
        set {
            LogSettings.store.set(newValue, forKey: LogSettings.printerKey) }
    }
    
    // Logs containing the given blacklist won’t be printed. The blacklist is a feature of the format. See the LogFormat class.
    var blackList: String {
        get {
            return LogSettings.store.string(forKey: LogSettings.blackListKey) ?? ""
        }
        set {
            LogSettings.store.set(newValue, forKey: LogSettings.blackListKey)
        }
    }
    
    /// Returns true if there is a debugger attached when this code is executed.
    private static func isDebuggerAttached() -> Bool {
        var info = kinfo_proc()
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        var size = MemoryLayout<kinfo_proc>.stride
        let junk = sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0)
        assert(junk == 0, "sysctl failed")
        return (info.kp_proc.p_flag & P_TRACED) != 0
    }
    
    /// Human-readable description.
    public var description: String {
        return [
            "BlackList: \"\(blackList)\"",
            "Level: \(level.description)",
            "Printer: \(printer.description)"
            ].joined(separator: ", ")
    }
}
