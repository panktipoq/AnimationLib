//
//  PoqPlatformTests.swift
//  PoqModuling-UnitTests
//
//  Created by Joshua White on 29/05/2018.
//

import XCTest
@testable import PoqModuling

class PoqPlatformTests: XCTestCase {
    
    func testAddModule() {
        class MockModule: PoqModule {
            var isAddedToPlatform = false
            
            func didAddToPlatform() {
                isAddedToPlatform = true
            }
        }
        
        let platform = PoqPlatform()
        
        let module1 = MockModule()
        platform.addModule(module1)
        XCTAssertTrue(module1.isAddedToPlatform)
        XCTAssertEqual(platform.modules.count, 1)
        XCTAssert(platform.modules.first === module1)
        
        let module2 = DefaultAppModule()
        platform.addModule(module2)
        XCTAssertEqual(platform.modules.count, 2)
        XCTAssert(platform.modules.first === module2)
    }
    
    func testRemoveModule() {
        class MockModule: PoqModule {
            var isRemovedFromPlatform = false
            
            func willRemoveFromPlatform() {
                isRemovedFromPlatform = true
            }
        }
        
        let platform = PoqPlatform()
        
        let module = MockModule()
        platform.addModule(module)
        XCTAssertEqual(platform.modules.count, 1)
        
        platform.removeModule(module)
        XCTAssertTrue(module.isRemovedFromPlatform)
        XCTAssertEqual(platform.modules.count, 0)
    }
    
    func testSetupAplication() {
        class MockModule: PoqModule {
            var isApplicationSetup = false
            
            func setupApplication() {
                isApplicationSetup = true
            }
        }
        
        let platform = PoqPlatform()
        
        let module = MockModule()
        platform.addModule(module)
        platform.addModule(DefaultAppModule())
        
        platform.setupApplication()
        XCTAssertTrue(module.isApplicationSetup)
    }
    
    func testResetApplication() {
        class MockModule: PoqModule {
            var isApplicationReset = false
            
            func resetApplication() {
                isApplicationReset = true
            }
        }
        
        let platform = PoqPlatform()
        
        let module = MockModule()
        platform.addModule(module)
        platform.addModule(DefaultAppModule())
        
        platform.resetApplication()
        XCTAssertTrue(module.isApplicationReset)
    }
    
    func testResolveViewController() {
        class MockModule: PoqModule {
            func createViewController(forName name: String) -> UIViewController? {
                return name == "ViewController" ? UIViewController() : nil
            }
        }
        
        let platform = PoqPlatform()
        
        let module = MockModule()
        platform.addModule(module)
        
        let fakeController = platform.resolveViewController(byName: "FakeController")
        XCTAssertNil(fakeController)
        
        let viewController = platform.resolveViewController(byName: "ViewController")
        XCTAssertNotNil(viewController)
    }
    
}
