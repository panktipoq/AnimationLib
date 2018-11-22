import Foundation

/// Log statement with the message and additional data for this message.
struct LogMessage {
    
    /// A copy of a regular expression that we will filter this message with.
    let blackList: String
    
    /// Human-readable name of the file where this log message originated.
    let file: Any?
    
    /// Human-readable name of the function where this log message originated.
    let function: String
    
    /// Human-readable name of the line where this log message originated.
    let line: UInt
    
    /// Log level for this log message. If the threshold level is higher, this message will be ignored.
    let level: LogLevel
    
    /// The log message itself.
    let message: String
}
