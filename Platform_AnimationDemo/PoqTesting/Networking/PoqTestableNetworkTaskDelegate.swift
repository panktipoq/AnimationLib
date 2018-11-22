//
//  PoqTestableNetworkTaskDelegate.swift
//  PoqDemoApp
//
//  Created by Gabriel Sabiescu on 11/12/2017.
//

import UIKit
import XCTest
import PoqNetworking

typealias MockNetworkTaskClosure = ((PoqNetworkTaskTypeProvider?, [Any]?, Error?) -> Void)

struct PoqNetworkTaskTest {
    
    var networkTaskType: PoqNetworkTaskTypeProvider
    var closure: MockNetworkTaskClosure
}

protocol PoqTestableNetworkTaskDelegate: AnyObject {
    
    var expectation: XCTestExpectation? { get set }
    var currentResult: [Any]? { get set }
    var expectedNetworkTasks: [PoqNetworkTaskTest] { get set }
    
    func listenFor(networkTaskType: PoqNetworkTaskTypeProvider, with closure: @escaping MockNetworkTaskClosure) -> PoqTestableNetworkTaskDelegate
    func mock(with expectation: XCTestExpectation, testCase: XCTestCase)
}

extension PoqTestableNetworkTaskDelegate {
    
    func listenFor(networkTaskType: PoqNetworkTaskTypeProvider, with closure: @escaping MockNetworkTaskClosure) -> PoqTestableNetworkTaskDelegate {
        let taskTest = PoqNetworkTaskTest(networkTaskType: networkTaskType, closure: closure)
        expectedNetworkTasks.append(taskTest)
        return self
    }
    
    func mock(with expectation: XCTestExpectation, testCase: XCTestCase) {
        
        self.expectation = expectation
        
        testCase.waitForExpectations(timeout: 25.0) { (error: Error?) in
            guard let validError = error else {
                return
            }
            XCTFail("The expectation failed: \(expectation.description) with error \(validError.localizedDescription)")
        }
    }
    
    private func filterOutNetworkTask(networkTaskType: PoqNetworkTaskTypeProvider) -> PoqNetworkTaskTest? {
        let networkTaskTests: [PoqNetworkTaskTest] = expectedNetworkTasks.filter({ $0.networkTaskType == networkTaskType })
        if networkTaskTests.count >= 1 {
            expectedNetworkTasks = expectedNetworkTasks.filter({ $0.networkTaskType != networkTaskType })  
            return networkTaskTests.first
            
        } else {
            XCTFail("Expected list of network task types does not contain \(networkTaskType.type)")
            return nil
        }
  
    }
    
    func finalize(networkTaskType: PoqNetworkTaskTypeProvider?, result: [Any]?, error: Error? = nil) {
        guard let validNetworkTaskType = networkTaskType else {
            XCTFail("Network task type is nil")
            return
        }

        self.currentResult = result
        
        if let validError = error {
            XCTFail("The expectation failed: \(String(describing: expectation?.description)) with error \(validError.localizedDescription)")
        } else if let validNetworkTaskTest = filterOutNetworkTask(networkTaskType: validNetworkTaskType) {
            if expectedNetworkTasks.count == 0 {
                expectation?.fulfill()
            }
            validNetworkTaskTest.closure(networkTaskType, result, error)
        }
    }
}
