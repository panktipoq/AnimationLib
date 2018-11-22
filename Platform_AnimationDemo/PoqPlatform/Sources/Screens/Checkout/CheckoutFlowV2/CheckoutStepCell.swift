//
//  NativeCheckoutStepCell.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 14/09/2016.
//
//

import UIKit

private let verticalLabelsIndent: CGFloat = 8

enum LeftAccessoryViewType {
    case none
    case stepNumber
    case image
}

public protocol CheckoutStep3LinePresentation {
    
    var stepNumber: Int? { get }
    
    /// We have 3 different styles of label,they depends on which line this label is. May be used only one this line
    var firstLine: String? { get }
    var secondLine: String? { get }
    var thirdLine: String? { get }

    var rightDetailText: String? { get }
}

open class CheckoutStepCell: UITableViewCell, TableCheckoutFlowStepOverViewCell {
    
    public static let reuseIdentifier: String = "CheckoutStepCell"
    public static let nibName: String = "CheckoutStepCell"
    
    /// For native checkout we will use 3 line oresentation. It will allow us use bold, regular and grey texts
    @IBOutlet public weak var firstLineLabel: UILabel? {
        didSet {
            firstLineLabel?.font = AppTheme.sharedInstance.nativeCheckoutFirstLineFont
            firstLineLabel?.textColor = AppTheme.sharedInstance.nativeCheckoutFirstLineColor
        }
    }
    
    @IBOutlet public weak var secondLineLabel: UILabel? {
        didSet {
            secondLineLabel?.font = AppTheme.sharedInstance.nativeCheckoutSecondLineFont
            secondLineLabel?.textColor = AppTheme.sharedInstance.nativeCheckoutSecondLineColor
        }
    }
    
    @IBOutlet public weak var thirdLineLabel: UILabel? {
        didSet {
              thirdLineLabel?.font = AppTheme.sharedInstance.nativeCheckoutThirdLineLabelLabelFont
              thirdLineLabel?.textColor = AppTheme.sharedInstance.nativeCheckoutThirdLineLabelLabelColor
        }
    }
    
    @IBOutlet weak var firstSecondVerticalDistance: NSLayoutConstraint?
    @IBOutlet weak var secondThirdVerticalDistance: NSLayoutConstraint?
    @IBOutlet weak var thirdBottomVerticalDistance: NSLayoutConstraint?
    
    @IBOutlet public weak var stepNumberLabel: UILabel? {
        didSet {
           stepNumberLabel?.textColor = AppTheme.sharedInstance.nativeCheckoutStepNumberTextColor
           stepNumberLabel?.font = AppTheme.sharedInstance.nativeCheckoutStepNumberTextFont
        }
    }
    @IBOutlet public weak var stepNumberWidth: NSLayoutConstraint?
    
    @IBOutlet public weak var rightLabel: UILabel?

    open override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    open func update(_ presentation: CheckoutStep3LinePresentation) {
        
        let strings: [String?] = [presentation.firstLine, presentation.secondLine, presentation.thirdLine]
        let labels: [UILabel?] = [firstLineLabel, secondLineLabel, thirdLineLabel]
        let constraints: [NSLayoutConstraint?] = [firstSecondVerticalDistance, secondThirdVerticalDistance, thirdBottomVerticalDistance]
        
        for index in 0..<3 {
            labels[index]?.text = strings[index]
            let empty: Bool = strings[index] == nil
            constraints[index]?.constant = empty ? 0.0 : verticalLabelsIndent
            labels[index]?.setContentHuggingPriority(empty ? UILayoutPriority(rawValue: 750.0) : UILayoutPriority(rawValue: 200.0), for: UILayoutConstraintAxis.vertical)
        }

        rightLabel?.text = presentation.rightDetailText
        
        if AppSettings.sharedInstance.nativeCheckoutShowStepNumbers {
            
            if let stepNumber = presentation.stepNumber {
                stepNumberLabel?.text = "\(stepNumber)"
            } else {
                stepNumberLabel?.text = ""
                stepNumberWidth?.constant = 10
            }
        } else {
            stepNumberLabel?.text = ""
            stepNumberWidth?.constant = 0
        }
    }
}
