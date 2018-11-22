//
//  Circle.swift
//  Poq.iOS
//
//  Created by Antonia Chekrakchieva on 5/5/16.
//
//

import UIKit

class Circle: UIView {

    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override open func draw(_ rect: CGRect) {

        layer.cornerRadius = frame.size.height/2 
        layer.masksToBounds = true
    }
    
    

}
