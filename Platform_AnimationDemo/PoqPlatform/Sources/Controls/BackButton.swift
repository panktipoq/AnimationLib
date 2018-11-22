//
//  BackButton.swift
//  Poq.iOS
//
//  Created by Jun Seki on 06/02/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import UIKit

@objc
public protocol BackButtonDelegate: AnyObject {
    @objc func backButtonClicked()
}

public final class BackButton: UIButton {
    
    // Strange way of migrating from UIView to UIButton 
    weak var delegate: BackButtonDelegate? {
        willSet {
            if let delegateUnwrapped = delegate {
                removeTarget(delegateUnwrapped, action: #selector(BackButtonDelegate.backButtonClicked), for: .touchUpInside)
            }
        }
        didSet {
            if let delegateUnwrapped = delegate {
                addTarget(delegateUnwrapped, action: #selector(BackButtonDelegate.backButtonClicked), for: .touchUpInside)
            }
        }
    }
    
    public override required init(frame: CGRect) {
        super.init(frame: frame)
        
        configurePoqButton(style: ResourceProvider.sharedInstance.clientStyle?.backButtonStyle)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configurePoqButton(style: ResourceProvider.sharedInstance.clientStyle?.backButtonStyle)
    }
}

extension BackButtonDelegate where Self: UIViewController {
    // MARK: - CloseButtonDelegate - BACK BUTTON ACTION FOR EVERY DETAIL VIEW CONTROLLER
    public func backButtonClicked() {
        navigationController?.popViewController(animated: true)
    }
}
