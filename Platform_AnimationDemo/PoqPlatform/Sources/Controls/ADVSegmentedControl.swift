//
//  ADVSegmentedControl.swift
//  Mega
// http://www.appdesignvault.com/custom-segmented-control-swift-tutorial/
//  Created by Tope Abayomi on 01/12/2014.
//  Copyright (c) 2014 App Design Vault. All rights reserved.
//

import UIKit

public class ADVSegmentedControl: UIControl {
    fileprivate var labels = [UILabel]()
    public var thumbView = UIView()
    public var borderWidht: CGFloat = 0
    public var items: [String] = []{
        didSet {
            setupLabels()
        }
    }
    
    public var selectedIndex : Int = 0 {
        didSet {
            displayNewSelectedIndex()
        }
    }
    public var unselectedLabelColor : UIColor = UIColor.black
    public var selectedLabelColor : UIColor = UIColor.white
    public var unselectedBackgroundColor : UIColor = UIColor.white
    public var selectedBackgroundColor : UIColor = UIColor.white
    public var thumbColor : UIColor = UIColor.white
    public var borderColor : UIColor = UIColor.white {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable public var font : UIFont! = UIFont(name: "Avenir-Black", size: 12) {
        didSet {
            setFont()
        }
    }
    public var selectedLabelFont : UIFont! = UIFont(name: "Avenir-Black", size: 14) {
        didSet {
            setFont()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required public init(coder: NSCoder) {
        super.init(coder: coder)!
        setupView()
    }
    
    func setupView(){
        setupLabels()
        addIndividualItemConstraints(labels, mainView: self, padding: 0)
        insertSubview(thumbView, at: 0)
    }
    
    
    func setupLabels(){
        for index in 0..<items.count {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 70, height: 40))
            label.text = items[index]
            label.textAlignment = .center
            label.font = font
            label.textColor = unselectedLabelColor
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            labels.append(label)
        }
        addIndividualItemConstraints(labels, mainView: self, padding: 0)
        
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        var selectFrame = self.bounds
        let newWidth = selectFrame.width / CGFloat(items.count)
        selectFrame.size.width = newWidth
        thumbView.frame = selectFrame
        displayNewSelectedIndex()
        
    }
    
    override open func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        
        var calculatedIndex : Int?
        for (index, item) in labels.enumerated() {
            if item.frame.contains(location) {
                calculatedIndex = index
            }
        }
        
        
        if calculatedIndex != nil {
            selectedIndex = calculatedIndex!
            sendActions(for: .valueChanged)
        }
        
        return false
        
    }

    func displayNewSelectedIndex(){
        for (_, item) in labels.enumerated() {
            item.textColor = unselectedLabelColor
            item.backgroundColor = unselectedBackgroundColor
            item.layer.borderWidth = borderWidht
            item.font = font
            
        }
        
        let label = labels[selectedIndex]
        label.textColor = selectedLabelColor
        label.backgroundColor = selectedBackgroundColor
        labels[selectedIndex].font = selectedLabelFont
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: UIViewAnimationOptions(), animations: {
            
            self.thumbView.frame = label.frame
            
            }, completion: nil)
    }
    
    func addIndividualItemConstraints(_ items: [UIView], mainView: UIView, padding: CGFloat) {
        
        _ = mainView.constraints
        
        for (index, button) in items.enumerated() {
            
            let topConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: mainView, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0)
            
            let bottomConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: mainView, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0)
            
            var rightConstraint : NSLayoutConstraint!
            
            if index == items.count - 1 {
                
                rightConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: mainView, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: -padding)
                
            }else{
                
                let nextButton = items[index+1]
                rightConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: nextButton, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: -padding)
            }
            
            
            var leftConstraint : NSLayoutConstraint!
            
            if index == 0 {
                
                leftConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: mainView, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: padding)
                
            }else{
                
                let prevButton = items[index-1]
                leftConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: prevButton, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: padding)
                
                let firstItem = items[0]
                
                let widthConstraint = NSLayoutConstraint(item: button, attribute: .width, relatedBy: NSLayoutRelation.equal, toItem: firstItem, attribute: .width, multiplier: 1.0  , constant: 0)
                
                mainView.addConstraint(widthConstraint)
            }
            
            mainView.addConstraints([topConstraint, bottomConstraint, rightConstraint, leftConstraint])
        }
    }
    
    
    func setFont(){
        for item in labels {
            item.font = font
        }
    }
}
