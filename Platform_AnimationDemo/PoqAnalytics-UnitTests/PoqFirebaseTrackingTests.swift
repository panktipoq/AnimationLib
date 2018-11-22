import XCTest
@testable import PoqAnalytics

class PoqFirebaseTrackingTests: XCTestCase {
    
    private let firebaseTracking = PoqFirebaseTracking()
    
    func testParamValueLengthChecker_nonString() {
        let integer = 0
        guard firebaseTracking.paramValueLengthChecker(forValue: integer) as? Int != nil else {
            XCTFail("Expected a parameter with type Int")
            return
        }
    }
    
    func testParamValueLengthChecker_string() {
        let string = "abc"
        guard firebaseTracking.paramValueLengthChecker(forValue: string) as? String != nil else {
            XCTFail("Expected a parameter with type String")
            return
        }
    }
    
    func testParamValueLengthChecker_stringTooLong() {
        let maxChars = firebaseTracking.firebaseMaxCharacterLength
        let string = type(of: self).randomDigitString(numberOfDigits: maxChars + 10)
        let result = firebaseTracking.paramValueLengthChecker(forValue: string)
        guard let stringResult = result as? Substring else {
            XCTFail("Expected a result with type String.")
            return
        }
        XCTAssert(stringResult.count == maxChars, "Returned strings are no longer than than \(maxChars) characters.")
    }

    private static func randomDigitString(numberOfDigits: Int) -> String {
        return (1...numberOfDigits).map({ _ in return Int(arc4random_uniform(10)).description }).joined()
    }
}
