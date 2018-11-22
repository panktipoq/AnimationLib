import XCTest
@testable import PoqPlatform

class FileTests: XCTestCase {
    
    /// When it reads a valid file, the file has a path, data, json, and the objects can be parsed.
    func testValidFile() {
        let file = TestFile(forResource: "FileTests-currencies", withExtension: "json")
        XCTAssertNotNil(file.findPath())
        XCTAssertNotNil(file.readData())
        XCTAssertNotNil(file.serialiseToJson())
        let currencies: [Currency]? = file.parse()
        XCTAssert(currencies?.count == 2)
    }
    
    /// When it reads an empty file, the file has a path and data but not json or objects.
    func testEmptyFile() {
        let file = TestFile(forResource: "FileTests-empty", withExtension: "json")
        XCTAssertNotNil(file.findPath())
        XCTAssertNotNil(file.readData())
        XCTAssertNil(file.serialiseToJson())
        let currencies: [Currency]? = file.parse()
        XCTAssertNil(currencies)
    }
    
    // When it reads an empty dictionary, the file has a path, data, json, but not objects.
    func testEmptyJsonDicFile() {
        let file = TestFile(forResource: "FileTests-emptyJsonDic", withExtension: "json")
        XCTAssertNotNil(file.findPath())
        XCTAssertNotNil(file.readData())
        XCTAssertNotNil(file.serialiseToJson())
        let currencies: [Currency]? = file.parse()
        XCTAssertNil(currencies)
    }
    
    // When it reads a missing file, all methods return nil.
    func testMissingFile() {
        let file = TestFile(forResource: "missing", withExtension: "file")
        XCTAssertNil(file.findPath())
        XCTAssertNil(file.readData())
        XCTAssertNil(file.serialiseToJson())
        let currencies: [Currency]? = file.parse()
        XCTAssertNil(currencies)
    }
}

// Subclass to override path and be able to read test files.
class TestFile: File {
    
    override func findPath() -> String? {
        let path = Bundle(for: FileTests.self).path(forResource: fileName, ofType: fileExtension)
        return path
    }
}
