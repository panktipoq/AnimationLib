/// Logging levels supported by the system.
public enum LogLevel: Int, CustomStringConvertible {
    
    /// Events useful during development and debugging in painful detail.
    case trace = 0
    
    /// Events useful during development and debugging.
    case debug = 1
    
    /// Information useful but not essential for troubleshooting.
    case info = 2
    
    /// Events that might result in a failure.
    case warn = 3
    
    /// Errors
    case error = 4
    
    /// No log. Everything log message will be ignored.
    case none = 5
    
    /// Human-readable description of this class.
    public var description: String {
        switch self {
        case .trace:
            return "TRACE"
        case .debug:
            return "DEBUG"
        case .info:
            return "INFO"
        case .warn:
            return "WARN"
        case .error:
            return "ERROR"
        case .none:
            return "NONE"
        }
    }
}

public func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
    return lhs.rawValue < rhs.rawValue
}
public func > (lhs: LogLevel, rhs: LogLevel) -> Bool {
    return lhs.rawValue > rhs.rawValue
}
public func <= (lhs: LogLevel, rhs: LogLevel) -> Bool {
    return lhs.rawValue <= rhs.rawValue
}
public func >= (lhs: LogLevel, rhs: LogLevel) -> Bool {
    return lhs.rawValue >= rhs.rawValue
}
