//
// Copyright 2016 Google Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// This file contains minor changes to improve sytax in a more swifty style.
//

import EarlGrey
import Foundation

public func GREYAssert(_ expression: @autoclosure () -> Bool, _ reason: String? = nil) {
    GREYAssert(expression, reason, details: "Expected expression to be true")
}

public func GREYAssertTrue(_ expression: @autoclosure () -> Bool, _ reason: String? = nil) {
    GREYAssert(expression(), reason, details: "Expected the boolean expression to be true")
}

public func GREYAssertFalse(_ expression: @autoclosure () -> Bool, _ reason: String? = nil) {
    GREYAssert(!expression(), reason, details: "Expected the boolean expression to be false")
}

public func GREYAssertNotNil(_ expression: @autoclosure ()-> Any?, _ reason: String? = nil) {
    GREYAssert(expression() != nil, reason, details: "Expected expression to be not nil")
}

public func GREYAssertNil(_ expression: @autoclosure () -> Any?, _ reason: String? = nil) {
    GREYAssert(expression() == nil, reason, details: "Expected expression to be nil")
}

public func GREYAssertEqual(_ left: @autoclosure () -> AnyObject?, _ right: @autoclosure () -> AnyObject?, _ reason: String? = nil) {
    GREYAssert(left() === right(), reason, details: "Expected left term to be equal to right term")
}

public func GREYAssertNotEqual(_ left: @autoclosure () -> AnyObject?, _ right: @autoclosure () -> AnyObject?, _ reason: String? = nil) {
    GREYAssert(left() !== right(), reason, details: "Expected left term to not equal the right term")
}

public func GREYAssertEqual<T: Equatable>( _ left: @autoclosure () -> T?, _ right: @autoclosure () -> T?, _ reason: String? = nil) {
    GREYAssert(left() == right(), reason, details: "Expected object of the left term to be equal to the object of the right term")
}

public func GREYAssertNotEqual<T: Equatable>( _ left: @autoclosure () -> T?, _ right: @autoclosure () -> T?, _ reason: String? = nil) {
    GREYAssert(left() != right(), reason, details: "Expected object of the left term to not equal the object of the right term")
}

public func GREYFail(_ reason: String? = nil, details: String = "") {
    EarlGrey.handle(exception: GREYFrameworkException(name: kGREYAssertionFailedException, reason: reason), details: details)
}

private func GREYAssert(_ expression: @autoclosure () -> Bool, _ reason: String?, details: String) {
    GREYSetCurrentAsFailable()
    GREYWaitUntilIdle()
    
    if !expression() {
        let expectation = GREYFrameworkException(name: kGREYAssertionFailedException, reason: reason)
        EarlGrey.handle(exception: expectation, details: details)
    }
}

private func GREYSetCurrentAsFailable() {
    let failureHandlerSelector = #selector(GREYFailureHandler.setInvocationFile(_:andInvocationLine:))
    let failureHandler = Thread.current.threadDictionary.value(forKey: kGREYFailureHandlerKey) as! GREYFailureHandler
    
    if failureHandler.responds(to: failureHandlerSelector) {
        failureHandler.setInvocationFile!(#file, andInvocationLine: #line)
    }
}

private func GREYWaitUntilIdle() {
    GREYUIThreadExecutor.sharedInstance().drainUntilIdle()
}

open class EarlGrey: NSObject {
    open class func selectElement(with matcher: GREYMatcher, file: StaticString = #file, line: UInt = #line) -> GREYElementInteraction {
        return EarlGreyImpl.invoked(fromFile: file.description, lineNumber: line).selectElement(with: matcher)
    }
    
    open class func elementExists(with matcher: GREYMatcher) {
        EarlGrey.selectElement(with: matcher).assertAnyExist()
    }
    
    open class func elementDoesNotExist(with matcher: GREYMatcher) {
        EarlGrey.selectElement(with: matcher).assert(grey_nil())
    }
    open class func setFailureHandler(handler: GREYFailureHandler, file: StaticString = #file, line: UInt = #line) {
        return EarlGreyImpl.invoked(fromFile: file.description, lineNumber: line).setFailureHandler(handler)
    }
    
    open class func handle(exception: GREYFrameworkException, details: String, file: StaticString = #file, line: UInt = #line) {
        return EarlGreyImpl.invoked(fromFile: file.description, lineNumber: line).handle(exception, details: details)
    }
    
    open class func rotateDeviceTo(orientation: UIDeviceOrientation, file: StaticString = #file, line: UInt = #line) throws {
        var rotationError: NSError?
        EarlGreyImpl.invoked(fromFile: file.description, lineNumber: line).rotateDevice(to: orientation, errorOrNil: &rotationError)
        if let error = rotationError { throw error }
    }
}

extension GREYInteraction {
    @discardableResult public func assert(_ matcher: @autoclosure () -> GREYMatcher) -> Self {
        return assert(with: matcher())
    }
    
    @discardableResult public func assert(_ matcher: @autoclosure () -> GREYMatcher, error: UnsafeMutablePointer<NSError?>!) -> Self {
        return assert(with: matcher(), error: error)
    }
    
    @discardableResult public func assertAnyExist() -> Self {
        var nserror: NSError?
        let result = assert(grey_notNil(), error: &nserror)
        
        // Check if there is an error and its not a multiple match error.
        // We want to skip multiple matches as we are testing for existance of any.
        if let error = nserror, !(error.domain == kGREYInteractionErrorDomain && error.code == 5) {
            // Otherwise we will throw the error.
            GREYFail(error.description)
        }
        
        return result
    }
    
    @discardableResult public func using(searchAction: GREYAction, onElementWithMatcher matcher: GREYMatcher) -> Self {
        return usingSearch(searchAction, onElementWith: matcher)
    }
}

extension GREYCondition {
    open func waitWithTimeout(seconds: CFTimeInterval) -> Bool {
        return wait(withTimeout: seconds)
    }
    
    open func waitWithTimeout(seconds: CFTimeInterval, pollInterval: CFTimeInterval) -> Bool {
        return wait(withTimeout: seconds, pollInterval: pollInterval)
    }
}
