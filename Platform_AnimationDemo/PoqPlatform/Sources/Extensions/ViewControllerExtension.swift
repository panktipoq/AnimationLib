//
//  ViewControllerExtension.swift
//  Poq.iOS
//
//  Created by Gabriel Sabiescu on 16/12/2016.
//
//

import Foundation
import PoqUtilities
import UIKit

public extension UIViewController {
    
    @nonobjc
    public func popDownToClass( className: AnyClass, animated: Bool ) {
        
        let viewControllerIndex = getViewFirstViewControllerByClassName( className: className )
        
        guard var validViewControllers = self.navigationController?.viewControllers else {
            return
        }
        
        if viewControllerIndex != -1 {
            let removeStart = viewControllerIndex + 1 // Not the one we're looking for but the one right next to it
            
            if removeStart < validViewControllers.count {
                validViewControllers.removeSubrange(removeStart..<validViewControllers.count)
            }
            
            
            self.navigationController?.setViewControllers(validViewControllers, animated: animated)
        } else
        {
            Log.debug("There is no \(className) viewcontroller inside navigation controller")
        }
    }
    
    @nonobjc
    public func goToRootViewController() -> UIViewController? {
        guard let validNavigationController = self.navigationController, let firstViewController = validNavigationController.viewControllers.first else {
            return nil
        }
        
        validNavigationController.setViewControllers([firstViewController], animated: true)
        return firstViewController
    }
    
    @nonobjc
    private func getViewFirstViewControllerByClassName( className: AnyClass ) -> Int {
        
        let viewControllers = self.navigationController?.viewControllers
        guard let count = viewControllers?.count else {
            return -1
        }
        
        for index in 0..<count {
            guard let viewController: UIViewController = viewControllers?[index] else {
                continue
            }
            
            
            if type(of: viewController) == className {
                return index
            }
            
            
        }
        return -1
    }
}
