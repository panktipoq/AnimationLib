@testable import PoqUtilities
import Foundation
import XCTest

class FormatTokenTests: XCTestCase {
    
    let payload = "Alice"
    let file = "Main"
    let function = "main"
    let line: UInt = 0
    let level = LogLevel.trace
    var message: LogMessage {
        return LogMessage(blackList: "", file: file, function: function, line: line, level: level, message: payload)
    }
    
    func testColor() {
        let log = FormatToken.color.transform(string: "", with: message)
        XCTAssert(log.contains(HexColors.gray))
    }
    
    func testDiscardIfMatching() {
        var log = FormatToken.discardIfMatching(regex: payload).transform(string: "", with: message)
        XCTAssert(log.isEmpty)
        log = FormatToken.discardIfMatching(regex: "Orange").transform(string: "Some accumulated string.", with: message)
        XCTAssert(log.count > 0, "Got “\(log)”, that’s \(log.count) characters")
    }
    
    func testLine() {
        let log = FormatToken.line.transform(string: "", with: message)
        XCTAssert(log.contains("\(line)"))
    }
    
    func testLiteral() {
        let literal = "X"
        let log = FormatToken.literal(literal).transform(string: "", with: message)
        XCTAssert(log.contains(literal))
    }
    
    func testLocation() {
        let log = FormatToken.location.transform(string: "", with: message)
        print(log)
        XCTAssert(log.contains(file))
        XCTAssert(log.contains(function))
    }
    
    func testLevel() {
        let log = FormatToken.level.transform(string: "", with: message)
        XCTAssert(log.contains("TRACE"))
    }
    
    func testMessage() {
        let log = FormatToken.message.transform(string: "", with: message)
        XCTAssert(log.contains(payload))
    }
    
    func testAlignRight() {
        let log = FormatToken.alignRight([.literal("A")], 3).transform(string: "", with: message)
        XCTAssert(log.contains("  A"))
    }
    
    func testResize() {
        var log = FormatToken.resize([.literal("A")], 3).transform(string: "", with: message)
        XCTAssert(log == "  A", "Got \(log)")
        
        log = FormatToken.resize([.literal("ABC")], 3).transform(string: "", with: message)
        XCTAssert(log == "ABC", "Got \(log)")
        
        log = FormatToken.resize([.literal("ABC")], 1).transform(string: "", with: message)
        XCTAssert(log == "…", "Got \(log)")
    }
    
    func testTimestamp() {
        let log = FormatToken.timestamp.transform(string: "", with: message)
        guard let hour = NSCalendar.current.dateComponents([Calendar.Component.hour], from: Date()).hour else {
            XCTFail("Couldn’t extract the current hour.")
            return
        }
        XCTAssert(log.contains("\(hour)"))
    }
}
