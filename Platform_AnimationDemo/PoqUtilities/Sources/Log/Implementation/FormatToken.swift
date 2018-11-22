import Foundation

/// Tokens you can use to create arbitrary format strings.
/// Each token will result in a string. Some tokens are also able to transform previously created strings.
enum FormatToken {
    
    /// Hexadecimal color with format #RRGGBB
    case color
    
    /// Human-readable description of the log level
    case level
    
    /// Class and function where the log statement was originated.
    case location
    
    /// Line of the class where the log statement was originated.
    case line
    
    /// A literal string
    case literal(String)
    
    /// The message itself.
    case message
    
    /// Align the string produced by the given token by adding spaces on the left.
    case alignRight([FormatToken], Int)
    
    /// Take the string produced by this token and truncate or pad left.
    case resize([FormatToken], Int)
    
    /// Date
    case timestamp
    
    /// Discards the accumulated string if it matches the regular expression
    case discardIfMatching(regex: String)
    
    /**
     Transforms a string using the current token instance and given message.
     */
    func transform(string: String, with msg: LogMessage) -> String {
        switch self {
        case .alignRight(let tokens, let size):
            let stringTokens = tokens.reduce("") { (result, token) -> String in
                return token.transform(string: result, with: msg)
            }
            return string + FormatToken.padStringLeft(string: stringTokens, to: size)
        case .color:
            return string + FormatToken.hexColor(for: msg.level)
        case .discardIfMatching(let regex):
            return FormatToken.isMatching(string: string, pattern: regex) ? "" : string
        case .line:
            return string + msg.line.description
        case .literal(let literal):
            return string + literal
        case .location:
            return string + FormatToken.originOf(classOrigin: msg.file) + "." + msg.function
        case .level:
            return string + "[\(msg.level.description)]"
        case .message:
            return string + msg.message
        case .resize(let tokens, let size):
            let stringTokens = tokens.reduce("") { (result, token) -> String in
                return token.transform(string: result, with: msg)
            }
            return string + FormatToken.resizeString(string: stringTokens, to: size)
        case .timestamp:
            return string + FormatToken.userVisibleDateFormatter.string(from: Date())
        }
    }
    
    private static var regExCache = [String: NSRegularExpression]()
    
    private static func padStringLeft(string: String, to padding: Int) -> String {
        return StringUtils.padLeft(string: string, toLength: padding)
    }
    
    // If the resulting string is shorter, the last character will be "…".
    private static func resizeString(string: String, to newLength: Int) -> String {
        guard string.count != newLength else {
            return string
        }
        let length = string.count
        if length < newLength {
            return StringUtils.padLeft(string: string, toLength: newLength)
        } else {
            let s = StringUtils.truncateTail(string: string, toLength: newLength)
            return StringUtils.replaceLastCharacter(string: s, character: "…")
        }
    }
    
    /**
     Returns true if the regular expression has at least one match in the given string.
     If the regular expression is not valid it will return false and print an error through NSLog.
     */
    private static func isMatching(string: String, pattern: String) -> Bool {
        guard !pattern.isEmpty else {
            return false
        }
        var cached = regExCache[pattern]
        if cached == nil {
            do {
                cached = try NSRegularExpression(pattern: pattern, options: [])
                regExCache[pattern] = cached
            } catch let error as NSError {
                NSLog(error.localizedDescription)
                return false
            }
        }
        guard let regEx = cached else {
            return false
        }
        let isMatch = regEx.firstMatch(in: string, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, string.count)) != nil
        return isMatch
    }
    
    private static let userVisibleDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
    
    private static func originOf(classOrigin: Any?) -> String {
        let origin: String
        if let classOrigin = classOrigin as? String {
            origin = URL(fileURLWithPath: classOrigin).deletingPathExtension().lastPathComponent
        } else if let any = classOrigin, let clazz = object_getClass(any as AnyObject) {
            let clazz = NSStringFromClass(clazz)
            origin = clazz.components(separatedBy: ".").last ?? ""
        } else {
            origin = ""
        }
        return origin
    }
    
    private static func hexColor(for level: LogLevel) -> String {
        switch level {
        case .trace:
            return HexColors.gray
        case .debug:
            return HexColors.white
        case .info:
            return HexColors.green
        case .none:
            return ""
        case .warn :
            return HexColors.yellow
        case .error:
            return HexColors.red
        }
    }
}
