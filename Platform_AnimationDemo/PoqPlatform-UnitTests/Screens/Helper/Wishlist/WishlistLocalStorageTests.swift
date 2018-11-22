//import XCTest
//@testable import PoqPlatform
//
//class WishlistLocalStorageTests: XCTestCase {
//    
//    let store = WishlistLocalStorage(store: RealmStore())
//    
//    override func setUp() {
//        super.setUp()
//        store.remove { _ in }
//    }
//    
//    override func tearDown() {
//        super.tearDown()
//        store.remove { _ in }
//    }
//    
//    typealias Completion = () -> Void
//    
//    private func perform(timeout: TimeInterval = 3.0, task: (@escaping Completion) -> Void) {
//        let exp = expectation(description: "Expected a call to fulfill()")
//        task({ exp.fulfill() })
//        waitForExpectations(timeout: timeout) { (error) in
//            error.flatMap { XCTFail("While waiting for expectations: \($0.localizedDescription)") }
//        }
//    }
//    
//    // When I add one favorite
//    func testAdd() {
//        
//        let productId = 1
//        perform { fulfill in
//            store.add(productId: productId) { result in
//                defer { fulfill() }
//                guard case .success(_) = result else {
//                    XCTFail("Caught an error while adding a product")
//                    return
//                }
//                // The amount of favorites is one
//                XCTAssert(self.store.favoritesCount() == 1, "The favorites count should be one after adding one product. It was \(self.store.favoritesCount()).")
//                
//                // The product id is favorited
//                XCTAssert(self.store.isFavorite(productId: productId), "The product \(productId) should be a favorite.")
//            }
//        }
//        
//        perform { fulfill in
//            // The product id can be read back
//            self.store.read { productIdentifiers in
//                defer { fulfill() }
//                XCTAssert(productIdentifiers.contains(productId), "The favorites should contain the previously added id \(productId). It was \(productIdentifiers).")
//            }
//        }
//    }
//    
//    func testRemove() {
//        store.remove { result in
//            guard case .success(_) = result else {
//                XCTFail("Caught an error while adding a product")
//                return
//            }
//            XCTAssert(self.store.favoritesCount() == 0, "The favorites count should be zero after removing all products. It was \(self.store.favoritesCount()).")
//        }
//    }
//    
//    func testReplace() {
//        
//        // When I replace all products with one
//        let productId = 1
//        perform { fulfill in
//            self.store.replace(productIds: Set([productId])) { result in
//                defer { fulfill() }
//                guard case .success(_) = result else {
//                    XCTFail("Caught an error while adding a product")
//                    return
//                }
//                // The amount of favorites is one
//                XCTAssert(self.store.favoritesCount() == 1, "The favorites count should be one after adding one product. It was \(self.store.favoritesCount()).")
//                // The product id is favorited
//                XCTAssert(self.store.isFavorite(productId: productId), "The product \(productId) should be a favorite.")
//            }
//        }
//        
//        // When I add the same product
//        perform { fulfill in
//            self.store.add(productId: productId) { result in
//                defer { fulfill() }
//                guard case .success(_) = result else {
//                    XCTFail("Caught an error while adding a product")
//                    return
//                }
//                // The favorites count remains the same
//                XCTAssert(self.store.favoritesCount() == 1, "Expected the favorites count to be one. It was \(self.store.favoritesCount()).")
//            }
//        }
//        
//        // When I add a different product
//        let differentProduct = 2
//        perform { fulfill in
//            self.store.add(productId: differentProduct) { result in
//                defer { fulfill() }
//                guard case .success(_) = result else {
//                    XCTFail("Caught an error while adding a product")
//                    return
//                }
//                // The favorites count is two
//                XCTAssert(self.store.favoritesCount() == 2, "Expected the favorites count to be two. It was \(self.store.favoritesCount()).")
//            }
//        }
//        
//        // If I replace the existing favorites with one product id
//        let otherProductId = 3
//        perform { fulfill in
//            self.store.replace(productIds: Set([otherProductId])) { result in
//                defer { fulfill() }
//                guard case .success(_) = result else {
//                    XCTFail("Caught an error while adding a product")
//                    return
//                }
//                // The amount of favorites is one
//                XCTAssert(self.store.favoritesCount() == 1, "The favorites count should be one after adding one product. It was \(self.store.favoritesCount()).")
//                // The product id is favorited
//                XCTAssert(self.store.isFavorite(productId: otherProductId), "The product \(otherProductId) should be a favorite.")
//            }
//        }
//    }
//}
