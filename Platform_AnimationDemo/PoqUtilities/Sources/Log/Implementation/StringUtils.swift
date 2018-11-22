import Foundation

public struct StringUtils {
    
    /// Repeat the given character to the left of the string until the string reaches the given length.
    public static func padLeft(string: String, toLength newLength: Int, withPad character: Character = " ") -> String {
        return pad(.left, string: string, toLength: newLength, withPad: character)
    }
    
    /// Repeat the given character to the right of the string until the string reaches the given length.
    public static func padRight(string: String, toLength newLength: Int, withPad character: Character = " ") -> String {
        return pad(.right, string: string, toLength: newLength, withPad: character)
    }
    
    /// Replace the last character of the string.
    public static func replaceLastCharacter(string: String, character: Character) -> String {
        return replaceCharacter(string: string, character: character, side: Side.right)
    }
    
    /// Discard the characters beyond the given length.
    public static func truncateTail(string: String, toLength newLength: Int) -> String {
        return truncate(.right, string: string, toLength: newLength)
    }
    
    private enum Side {
        case left, right
    }
    
    private static func pad(_ side: Side, string: String, toLength newLength: Int, withPad character: Character = " ") -> String {
        let length = string.count
        guard newLength > length else {
            return string
        }
        let spaces = String(repeatElement(character, count: newLength - length))
        return side == .left ? spaces + string : string + spaces
    }
    
    private static func truncate(_ dropSide: Side, string: String, toLength newLength: Int) -> String {
        let length = string.count
        guard newLength < length else {
            return string
        }
        if dropSide == .left {
            let offset = -1 * newLength + 1
            let index = string.index(string.endIndex, offsetBy: offset)
            return "…" + String(string.suffix(from: index))
        } else {
            let offset = newLength - 1
            let index = string.index(string.startIndex, offsetBy: offset)
            return String(string.prefix(upTo: index)) + "…"
        }
    }
    
    private static func replaceCharacter(string: String, character: Character, side: Side) -> String {
        guard string.count > 1 else {
            return string
        }
        var s = string
        switch side {
        case .left:
            s.remove(at: s.startIndex)
            return "\(character)\(s)"
        case .right:
            s.remove(at: s.index(before: s.endIndex))
            return "\(s)\(character)"
        }
    }
}
