//
//  VersionInfoCell.swift
//  Poq.iOS.Platform
//
//  Created by Manuel Marcos Regalado on 20/07/2017.
//
//

import Foundation
import UIKit

class VersionInfoCell: FullWidthAutoresizedCollectionCell {

    static let height: CGFloat = 30

    @IBOutlet weak var buildNumberLabel: UILabel? {
        didSet {
            buildNumberLabel?.text = AppSettings.sharedInstance.versionBuildAPINumbers
        }
    }
}
