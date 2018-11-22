//
//  MySizesSelectionViewController.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 08/04/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqNetworking
import UIKit

protocol MySizesSelectionDelegate{
    
    func mySizeSelected(_ sizeId:String)
}

class MySizesSelectionViewController: PoqBaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    // ______________________________________________________
    
    // MARK: Class variables
    var mySize:PoqMySize?
    var mySizeType:MySizeType = MySizeType.WOMAN
    var mySizes:[PoqSize] = []
    var selectionDelegate:MySizesSelectionDelegate?
    
    // Cell attributes
    var mySizeCellIdentifier = "mySizeSelectionCellIdentifier"
    var mySizeCellHeight = CGFloat(50)
    
    @IBOutlet weak var tableView: UITableView!
    
    // ______________________________________________________
    
    // MARK: UI delegates
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.mySize != nil {
            
            // Get selected sizes
            if let mySizeCategories = self.mySize?.mySizesCategories {
                
                // Traverse size categories
                for mySizeCategory in mySizeCategories {
                    
                    // Find the size title of the cell, i.e. Womens
                    if let mySizeCategoryTitle = mySizeCategory.title {
                        
                        if mySizeCategoryTitle == self.mySizeType.rawValue {
                            
                            // Traverse my sizes data until isSelected found for a size
                            if let mySizes = mySizeCategory.mySizes {
                                
                                self.mySizes = mySizes
                                break
                            }
                        }
                    }
                }
            }
            
            
            // Set navigation title
            if let title = self.mySize?.title{
                self.navigationItem.titleView = NavigationBarHelper.setupTitleView(title, titleFont: AppTheme.sharedInstance.mySizesNavigationTitleFont)
            }

        }
        
        
        // Set back button and disable hamburger menu
        self.navigationItem.leftBarButtonItem = NavigationBarHelper.setupBackButton(self)
        self.navigationItem.rightBarButtonItem = nil
        
        
        // Hide empty cells
        self.tableView?.tableFooterView = UIView(frame: CGRect.zero)
        
        // Show table
        self.tableView?.reloadData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    // ______________________________________________________
    
    // MARK: Table delegates
    
    
    // Set number of rows (data.count)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mySizes.count
    }
    
    // Set number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Render cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: self.mySizeCellIdentifier)
        
        if (cell == nil){
            
            // Init cell with subtitle (title + description)
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: self.mySizeCellIdentifier)
        }
    
        // Get my size
        let size = self.mySizes[indexPath.row]
        let mySizeTitle = size.size != nil ? size.size! : ""
        
        cell?.tintColor = AppTheme.sharedInstance.tabBarSelectedTintColor
        
        var isMarked = false
        
        if let selected = size.isSelected{
            
            isMarked = selected
        }
        
        cell?.accessoryType = isMarked ? UITableViewCellAccessoryType.checkmark : UITableViewCellAccessoryType.none
        
        // Set mysize name
        cell?.textLabel?.text = mySizeTitle
        cell?.textLabel?.font = AppTheme.sharedInstance.mySizesSelectionNameLabelFont
        
        if isMarked {
            
            cell?.textLabel?.textColor = AppTheme.sharedInstance.tabBarSelectedTintColor
        }
        else {
            
            cell?.textLabel?.textColor = UIColor.black
        }

        
        
        return cell!
    }
    
    // Set cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return self.mySizeCellHeight
        
    }
    
    // Listen item selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Dismiss the selection
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let selectionDelegate = self.selectionDelegate {
            
            // Track selected size
            PoqTrackerHelper.trackMySize(self.mySize!.title!, label: self.mySizes[indexPath.row].size!, extraParams: ["Size ID" : String(self.mySizes[indexPath.row].id!)])
            
            // Remove current view and call delegate
            let _ = navigationController?.popViewController(animated: true)
            selectionDelegate.mySizeSelected(String(self.mySizes[indexPath.row].id!))

        }
    }
    
    // ______________________________________________________
    
    // MARK: Utilities
    
    
    override func backButtonClicked() {
        
        self.selectionDelegate = nil
        super.backButtonClicked()
    }
}
