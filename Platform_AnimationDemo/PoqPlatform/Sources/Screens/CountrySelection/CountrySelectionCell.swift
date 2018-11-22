//
//  CountrySelectionCell.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 29/01/2016.
//
//

import UIKit

open class CountrySelectionCell: UITableViewCell {
    
    static let CellReuseIdentifier: String = "CountrySelectionCell"

    @IBOutlet weak var countryFlagImageView: UIImageView!
    @IBOutlet public weak var countryNameLabel: UILabel!{
        didSet {
            countryNameLabel.font = AppTheme.sharedInstance.countrySelectionCellTextFont
            countryNameLabel.textColor = AppTheme.sharedInstance.countrySelectionCellTextColor
        }
    }

}
