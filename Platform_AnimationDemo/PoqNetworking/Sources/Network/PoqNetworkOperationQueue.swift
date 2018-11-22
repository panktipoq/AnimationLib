//
//  PoqNetworkOperationQueue.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 26/08/2016.
//
//

import Foundation
import PoqUtilities

open class PoqNetworkOperationQueue: OperationQueue {
    
    override open func addOperation(_ op: Operation) {
        guard let networkOperation: PoqNetworkOperation = op as? PoqNetworkOperation else {
            Log.error("We can't add non network task in queue")
            return
        }
        
        networkOperation.notifyDelegateThatTaskStarted()

        super.addOperation(op)
    }
    
}


