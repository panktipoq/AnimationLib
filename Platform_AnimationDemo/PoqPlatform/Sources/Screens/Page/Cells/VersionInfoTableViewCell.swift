//
//  VersionInfoTableViewCell.swift
//  Poq.iOS.Platform
//
//  Created by Manuel Marcos Regalado on 01/08/2017.
//
//

import Foundation

class VersionInfoTableViewCell: UITableViewCell {
    
    static let height: CGFloat = 30
    
    @IBOutlet weak var buildNumberLabel: UILabel? {
        didSet {
            buildNumberLabel?.text = AppSettings.sharedInstance.versionBuildAPINumbers
        }
    }
}
