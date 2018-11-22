//
//  TabBarBadgeView.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 11/02/2016.
//
//

import UIKit

class TabBarBadgeView: UIView {
    
    static let iPadBadgeLeftOffset: CGFloat = 54
    static let iPhoneBadgeCenterOffsetPercentage: CGFloat = 0.18
    
    lazy var badgeLabel: UILabel = {

        var badgeLabel = UILabel()
        badgeLabel.textColor = AppTheme.sharedInstance.badgeTextColor
        badgeLabel.font = AppTheme.sharedInstance.badgeFont
        badgeLabel.textAlignment = NSTextAlignment.center
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(badgeLabel)
        let labelInsets: UIEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 4)
        let constraints: [NSLayoutConstraint] = NSLayoutConstraint.constraintsForView(badgeLabel, withInsetsInContainer: labelInsets)
        self.addConstraints(constraints)
        
        return badgeLabel
    }()
    
    var badgeText: String = "" {
        didSet {
            badgeLabel.text = badgeText
        }
    }
    
    weak var tabBarItem: UIView?
    weak var tabBarController: UITabBarController?
    
    var positionConstraint: [NSLayoutConstraint] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    init() {
        super.init(frame: CGRect.zero)
        commonInit()
    }
    
    // MARK: UIView override
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = ceil(self.frame.height / 2)
        
        if positionConstraint.count > 1 {
            let horConstraint: NSLayoutConstraint = positionConstraint[1]
            horConstraint.constant = leftShiftOfBadgeView()
        }
    }
    
    func attachTo(_ tabBarItemView: UIView, tabBarController: UITabBarController) {
        
        tabBarController.tabBar.addSubview(self)

        tabBarItem = tabBarItemView
        self.tabBarController = tabBarController
        
        forceUpdateConstraints()
        
    }
    
    override func willMove(toWindow window: UIWindow?) {
        super.willMove(toWindow: window)
        
        self.isHidden = window == nil

    }

    override func didMoveToWindow() {
        super.didMoveToWindow()

        forceUpdateConstraints()
    }
    
    // MARK: Private

    fileprivate func commonInit() {
        
        self.backgroundColor = AppTheme.sharedInstance.badgeBackgroundColor
        self.clipsToBounds = true
        
        
        self.layer.borderColor = AppTheme.sharedInstance.badgeBorderColor.cgColor
        self.layer.borderWidth = 2
        
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    fileprivate func leftShiftOfBadgeView() -> CGFloat {
        guard let existedTabBarItem = tabBarItem else  {
            return 0
        }
        if DeviceType.IS_IPAD {
            
            return TabBarBadgeView.iPadBadgeLeftOffset
            
        } else {
            
            return TabBarBadgeView.iPhoneBadgeCenterOffsetPercentage * existedTabBarItem.frame.width
            
        }
    }
    
    fileprivate func forceUpdateConstraints() {
        
        guard let existTabBarItemView: UIView = tabBarItem,
            let existedTabBarView: UIView = tabBarController?.view,
            let _: UIWindow = self.window  else {
                return
        }
        
        // remove old constraints if exists
        if positionConstraint.count > 0 {
            NSLayoutConstraint.deactivate(positionConstraint)
        }

        let topConstraint: NSLayoutConstraint = NSLayoutConstraint(item: self,
            attribute: NSLayoutAttribute.centerY,
            relatedBy: NSLayoutRelation.equal,
            toItem: existTabBarItemView,
            attribute: NSLayoutAttribute.centerY,
            multiplier: 0.50,
            constant: 0)
        
        var horConstraint: NSLayoutConstraint = NSLayoutConstraint(item: self,
            attribute: NSLayoutAttribute.centerX,
            relatedBy: NSLayoutRelation.equal,
            toItem: existTabBarItemView,
            attribute: NSLayoutAttribute.centerX,
            multiplier: 1,
            constant: leftShiftOfBadgeView())
        
        if DeviceType.IS_IPAD {
            
            horConstraint = NSLayoutConstraint(item: self,
            attribute: NSLayoutAttribute.leading,
            relatedBy: NSLayoutRelation.equal,
            toItem: existTabBarItemView,
            attribute: NSLayoutAttribute.leading,
            multiplier: 1,
            constant: leftShiftOfBadgeView())
        }

        
        positionConstraint = [topConstraint, horConstraint]
        existedTabBarView.addConstraints(positionConstraint)
    
    }

}
