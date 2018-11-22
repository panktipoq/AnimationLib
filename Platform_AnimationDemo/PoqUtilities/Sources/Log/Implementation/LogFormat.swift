import Foundation

// Arbitrary log formats.
enum LogFormat {
    
    // Prints log statements as: `Class.function:line - message`
    case simple(blackList: String)
    
    // Prints log statements as: `[level] Class.function:line - message`
    case `default`
    
    // Prints log statements as: `#hexColor [level] Class.function:line - message`
    case colored(blackList: String)
    
    func tokens() -> [FormatToken] {
        switch self {
            
        case .simple(let blackList):
            return [
                .location,
                .literal(":"),
                .line,
                .literal(" - "),
                .message,
                .discardIfMatching(regex: blackList) // Discard the whole string up to this point if it matches the given regular expression
            ]
            
        case .`default`:
            return [
                .level,
                .literal(" "),
                .resize([.location], 40), // Resize the "[level] location" string to 40 characters
                .literal(":"),
                .alignRight([.line], 3), // Pad the line number to three characters and align it right
                .literal(" - "),
                .message
            ]
            
        case .colored(let blackList):
            return [
                .color,
                .level,
                .literal(" "),
                .resize([.location], 40),
                .literal(":"),
                .alignRight([.line], 3),
                .literal(" - "),
                .message,
                .discardIfMatching(regex: blackList) // Discard the whole string up to this point if it matches the given regular expression
            ]
        }
    }
}
