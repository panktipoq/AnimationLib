//
//  MyProfileAddressBookTitleTableViewCell.swift
//  Poq.iOS
//
//  Created by Antonia Chekrakchieva on 11/11/15.
//  Copyright © 2015 Poq. All rights reserved.
//

import UIKit

public protocol PoqTitleBlock: AnyObject {
    func getPoqTitleBlock(_ tableView: UITableView, indexPath: IndexPath, title: String, font: UIFont) -> UITableViewCell
    func hasTitle(_ indexPath: IndexPath) -> Bool
}

extension PoqTitleBlock {
    public func getPoqTitleBlock(_ tableView: UITableView, indexPath: IndexPath, title: String, font: UIFont = AppTheme.sharedInstance.addressTypeFont) -> UITableViewCell {
        
        let cell: MyProfileAddressBookTitleTableViewCell = tableView.dequeueReusablePoqCell(forIndexPath: indexPath)
        cell.titleLabel?.font = font
        cell.setUp(title)
        return cell
    }
    public func hasTitle(_ indexPath: IndexPath) -> Bool {
        return indexPath.row == 0 && AppSettings.sharedInstance.addressTypeTitleEnabled
    }
    
}

public class MyProfileAddressBookTitleTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel?    

    override public func awakeFromNib() {
        super.awakeFromNib()
        titleLabel?.font = AppTheme.sharedInstance.addressTypeFont
        titleLabel?.textColor = AppTheme.sharedInstance.addressTypeColour
        isUserInteractionEnabled = false
    }
    
    func setUp(_ text: String) {
        titleLabel?.text = text
    }
}

extension MyProfileAddressBookTitleTableViewCell: MyProfileCell {
    
    /// Updates the UI accordingly
    ///
    /// - Parameters:
    ///   - item: The content item that populates the cell
    ///   - delegate: The delegate that receives the calls as a result of the cell actions
    public func updateUI(_ item: MyProfileContentItem, delegate: MyProfileCellsDelegate?) {
        titleLabel?.text = item.firstInputItem.value
    }
}
