//
//  MyProfileBarcodeFullscreenViewController.swift
//  Poq.iOS
//
//  Created by Barrett Breshears on 3/16/15.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import UIKit

class MyProfileBarcodeFullscreenViewController: PoqBaseViewController {

    @IBOutlet var barcodeValue1: UILabel?
    @IBOutlet var barcodeValue2: UILabel?
    @IBOutlet var barcodeValue3: UILabel?
    @IBOutlet var barcodeValue4: UILabel?
    var barcodeValue: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PoqTrackerHelper.trackScannBarcode()
        self.navigationItem.titleView = NavigationBarHelper.setupTitleView(AppLocalization.sharedInstance.fullScreenBarcodeNavigationTitle,
                                                                             titleFont: AppTheme.sharedInstance.fullScreenBarcodeNaviTitleFont)
        
        //set up back button
        self.navigationItem.leftBarButtonItem = NavigationBarHelper.setupCloseButton(self)
        self.navigationItem.rightBarButtonItem = nil
        
        if let barcode = barcodeValue {
            let codeLength = barcode.count
            
            // seperate barcode string into 4 parst to display
            // on 4 seperate labels
            self.barcodeValue1?.text = barcode[0...3]
            self.barcodeValue2?.text = barcode[4...7]
            self.barcodeValue3?.text = barcode[8...11]
            self.barcodeValue4?.text = barcode[12...codeLength - 1]
        }
        barcodeValue1?.font = AppTheme.sharedInstance.fullScreenBarcodeTextFont
        barcodeValue2?.font = AppTheme.sharedInstance.fullScreenBarcodeTextFont
        barcodeValue3?.font = AppTheme.sharedInstance.fullScreenBarcodeTextFont
        barcodeValue4?.font = AppTheme.sharedInstance.fullScreenBarcodeTextFont
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func closeButtonClicked() {
        dismiss(animated: true, completion: nil)
    }

}
