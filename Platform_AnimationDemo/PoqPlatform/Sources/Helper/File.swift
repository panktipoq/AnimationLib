import ObjectMapper
import PoqUtilities

/// Methods to read a file.
class File: CustomStringConvertible {
    
    let fileName: String
    let fileExtension: String
    
    /// Initializes the representation of a file, without testing if that file exists.
    init(forResource: String, withExtension ofType: String) {
        self.fileName = forResource
        self.fileExtension = ofType
    }
    
    /// Return the contents of this file as an array of T.
    func parse<T: Codable>() -> [T]? {
        guard let data = readData() else {
            return nil
        }
        let decodedData = try? JSONDecoder().decode([T].self, from: data)
        return decodedData
    }
    
    /// Return the contents of this file as JSON.
    func serialiseToJson() -> Any? {
        guard let data = readData() else {
            return nil
        }
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
            Log.warning("Failed to parse \(self) as JSON.")
            return nil
        }
        return json
    }
    
    /// Return the contents of this file as Data.
    func readData() -> Data? {
        return findPath().flatMap {
            try? Data(contentsOf: URL(fileURLWithPath: $0), options: .mappedIfSafe)
        }
    }
    
    /// Return the path to this file in any of the modules of the Poq Platform.
    func findPath() -> String? {
        let path = ResourceFinder.path(forResource: fileName, ofType: fileExtension)
        if path == nil {
            Log.warning("Expected file \(self) in the bundle.")
        }
        return path
    }
    
    var description: String {
        return "\(fileName).\(fileExtension)"
    }
}
