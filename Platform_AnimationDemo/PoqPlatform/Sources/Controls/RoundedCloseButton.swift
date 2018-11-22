//
//  RoundedCloseButton.swift
//  Poq.iOS.Platform
//
//  Created by Mohamed Arradi-Alaoui on 08/06/2017.
//
//

import Foundation
import UIKit

open class RoundedCloseButton: UIButton {
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        initCloseButtonRoundedStyle()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initCloseButtonRoundedStyle()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initCloseButtonRoundedStyle()
    }
    
    fileprivate func initCloseButtonRoundedStyle() {
        configurePoqButton(style: ResourceProvider.sharedInstance.clientStyle?.closeButtonRoundedStyle)
    }
}
