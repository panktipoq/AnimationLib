/**
 Abstract class for log implementations.
 This is a class and not a protocol because protocols don’t allow default parameters, which is an essential feature to implement logging.
 */
public class AbstractLog {
    public var level = LogLevel.warn
    public func verbose (_ message: @autoclosure () -> String, _ file: Any? = #file, _ function: String = #function, _ line: UInt = #line) {}
    public func debug   (_ message: @autoclosure () -> String, _ file: Any? = #file, _ function: String = #function, _ line: UInt = #line) {}
    public func info    (_ message: @autoclosure () -> String, _ file: Any? = #file, _ function: String = #function, _ line: UInt = #line) {}
    public func warning (_ message: @autoclosure () -> String, _ file: Any? = #file, _ function: String = #function, _ line: UInt = #line) {}
    public func error   (_ message: @autoclosure () -> String, _ file: Any? = #file, _ function: String = #function, _ line: UInt = #line) {}
}
