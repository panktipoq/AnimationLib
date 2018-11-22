//
//  PoqPresenter.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Mahmut Canga on 21/12/2016.
//
//

import Foundation
import PoqNetworking
import PoqUtilities
import UIKit

// ______________________________________________________

/// Fundamental presentation states

public enum PoqPresenterState {
    
    case loading
    case empty
    case error
    case completed
}

public protocol PoqPresenter: AnyObject {
    
    // ______________________________________________________
    
    // MARK: - Properties
    
    // ______________________________________________________
    
    // MARK: - Methods
    
    func update(state: PoqPresenterState, networkTaskType: PoqNetworkTaskTypeProvider, withNetworkError networkError: NSError?)
    func loading()
    func empty()
    func error(_ networkError: NSError?)
    func completed(_ networkTaskType: PoqNetworkTaskTypeProvider)
    
    func createSpinnerView()
    func removeSpinnerView()
    func showErrorMessage(_ networkError: NSError?)
}

// Group common UI functionality in this extension

extension PoqPresenter {
    
    public func update(state: PoqPresenterState, networkTaskType: PoqNetworkTaskTypeProvider, withNetworkError networkError: NSError? = nil) {
        
        switch state {
            
        case .loading:
            createSpinnerView()
            loading()
            
        case .empty:
            removeSpinnerView()
            empty()
            
        case .error:
            removeSpinnerView()
            Log.warning("A networkTaskType \(networkTaskType.type) returned an error.")
            error(networkError)
            
        case .completed:
            removeSpinnerView()
            completed(networkTaskType)
        }
    }
}

extension PoqPresenter {
    
    public func loading() {
        
        // Can be implemented for custom loading state
    }
    
    public func empty() {
        
        // Can be implemented for custom empty state
    }
    
    public func error(_ networkError: NSError?) {
        
        removeSpinnerView()
        showErrorMessage(networkError)
    }
    
}

// ______________________________________________________

// MARK: - Platform Functionality

public protocol ViewOwner {
    var view: UIView! { get }
}

extension PoqPresenter where Self: ViewOwner {
    
    var spinnerView: PoqSpinner? {
        
        for subview in view.subviews where subview is PoqSpinner {
            return subview as? PoqSpinner
        }
        
        return nil
    }
    
    public func createSpinnerView() {
        
        // Lets avoid recreating spinner view
        let newSpinnerView: PoqSpinner
        if let existed = spinnerView {
            newSpinnerView = existed
        } else {
            newSpinnerView = PoqSpinner(frame: CGRect.zero)
            
            view.addSubview(newSpinnerView)
            
            newSpinnerView.translatesAutoresizingMaskIntoConstraints = false
            newSpinnerView.applyCenterPositionConstraints()
        }
        
        newSpinnerView.tintColor = AppTheme.sharedInstance.mainColor
        
        newSpinnerView.startAnimating()
    }
    
    public func removeSpinnerView() {
        
        guard let spinnerViewValidated = spinnerView else {
            Log.error("Spinner view is not found.")
            
            return
        }
        
        spinnerViewValidated.stopAnimating()
        spinnerViewValidated.removeFromSuperview()
    }
}

extension PoqPresenter where Self: PoqBaseViewController {
    
    public func showErrorMessage(_ networkError: NSError?) {
        
        let errorTitle: String
        let errorMessage: String?
        
        if let validErrorMessage = networkError?.localizedDescription {
            
            errorTitle = validErrorMessage
            errorMessage = nil
            
        } else {
            
            errorTitle = "CONNECTION_ERROR".localizedPoqString
            errorMessage = "TRY_AGAIN".localizedPoqString
            if NSClassFromString("XCTestCase") != nil {
                Log.info("Skipping the 'connection error' popup because we are testing.")
                return
            }
        }
        
        let validAlertController = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        alertController = validAlertController
        
        validAlertController.addAction(UIAlertAction.init(title: "OK".localizedPoqString, style: UIAlertActionStyle.default, handler: { (alertaction: UIAlertAction) in
            // Nothing to do for now
        }))
        
        present(validAlertController, animated: true) {
            // Completion handler once everything is dismissed
        }
    }
}
