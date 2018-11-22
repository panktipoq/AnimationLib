//
//  PoqProductActionContentBlockView.swift
//  Poq.iOS.Belk
//
//  Created by Robert Dimitrov on 2/10/17.
//
//

import PoqModuling
import PoqNetworking
import PoqUtilities
import UIKit

open class PoqProductActionContentBlockView: FullWidthAutoresizedCollectionCell, PoqProductDetailCell, PoqLinkBlock {

    @IBOutlet public weak var titleLabel: UILabel?
    @IBOutlet public weak var actionButton: UIButton?
    @IBOutlet public weak var spaceView: UIView?
    
    @IBOutlet public weak var separator: SolidLine?
    
    open var content: PoqProductDetailContentItem?
    
    weak open var presenter: PoqProductBlockPresenter?
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        actionButton?.configurePoqButton(style: ResourceProvider.sharedInstance.clientStyle?.secondaryButtonStyle)
        actionButton?.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.light)
        spaceView?.backgroundColor = AppTheme.sharedInstance.plpCollectionViewBackgroundColor
    }
    
    @IBAction open func openDeeplink(_ sender: UIButton) {
        guard let contentItemType = content?.cellType as? PoqProductDetailCellType else {
            Log.error("Wrong content item type sent to cell.")
            return
        }
        
        if case PoqProductDetailCellType.link(let link) = contentItemType {
            
            openLink(link)
            
        } else if case PoqProductDetailCellType.action(let action) = contentItemType {
            action()
        }
    }
    
    // MARK: - PoqProductDetailResuableView
    
    open func setup(using content: PoqProductDetailContentItem, with product: PoqProduct?) {
        self.content = content
        
        titleLabel?.text = content.description
        
        actionButton?.setTitle(content.title ?? "", for: .normal)
        actionButton?.isHidden = (content.title?.length == 0)
    }
}
