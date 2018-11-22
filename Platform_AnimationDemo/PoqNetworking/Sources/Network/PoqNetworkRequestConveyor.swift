//
//  PoqNetworkRequestConveyor.swift
//  Poq.iOS.Platform
//
//  Created by Nikolay Dzhulay on 4/11/17.
//
//

import Foundation

/// While we increate functionality, we require more additional influence on requests
/// For example, in preview/debug mode app should send additional headers
/// Before we will convert PoqNetworkRequest into URLRequest, it will go through all registered PoqNetworkRequestConveyorStep
public class PoqNetworkRequestConveyor {

    fileprivate static var steps = [PoqNetworkRequestConveyorStep]()
    
    /// Add step, if stpe with type T exists - replace it
    public static func add<T: PoqNetworkRequestConveyorStep>(step: T) {
        steps = steps.filter { 
            (step: PoqNetworkRequestConveyorStep) in
            return type(of: step) != T.self
        }
        steps.append(step)
    }
    
    /// Remove step with type T, return removed step if it was found
    @discardableResult
    public static func remove<T: PoqNetworkRequestConveyorStep>() -> T? {

        let indexOrNil = steps.index { 
            (step: PoqNetworkRequestConveyorStep) in
            return type(of: step) == T.self
        }

        var removedStep: T?

        if let index = indexOrNil {
            removedStep = steps.remove(at: index) as? T
        }

        return removedStep
    }

    public static func runConveyor(on request: PoqNetworkRequest) {
        for step in steps {
            step.run(on: request)
        }
    }
}

/// Describe Conveyor Step. Fill free add headers and query parameters to request
/// Step don't have order, which means, should works independetly from each other
/// Step with type T can be presented in conveyor only once
public protocol PoqNetworkRequestConveyorStep {

    func run(on request: PoqNetworkRequest)
}

