//
//  PoqProductShareContentBlockView.swift
//  Poq.iOS.Platform
//
//  Created by Nikolay Dzhulay on 6/20/17.
//
//

import Foundation
import PoqNetworking
import UIKit

open class PoqProductShareContentBlockView: FullWidthAutoresizedCollectionCell, PoqProductDetailCell {
    
    @IBOutlet weak var shareButton: UIButton? {
        didSet {
            shareButton?.isAccessibilityElement = true
            shareButton?.accessibilityIdentifier = AccessibilityLabels.pdpShare
        }
    }
    
    // MARK: PoqProductDetailCell
    public weak var presenter: PoqProductBlockPresenter?
    public func setup(using content: PoqProductDetailContentItem, with product: PoqProduct?) {
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        let style = ResourceProvider.sharedInstance.clientStyle?.pdpShareButtonStyle
        shareButton?.configurePoqButton(style: style)
    }

    @IBAction public func shareButtonAction(sender: Any?) {
        presenter?.shareDidTap(sender: shareButton)
    }
}


