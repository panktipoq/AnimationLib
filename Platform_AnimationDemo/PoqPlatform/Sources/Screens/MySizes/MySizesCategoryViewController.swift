//
//  MySizesCategoryViewController.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 08/04/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqNetworking
import UIKit

protocol MySizesCategoryDelegate{
    
    func updateSizes()
}

class MySizesCategoryViewController : PoqBaseViewController, UITableViewDelegate, UITableViewDataSource, MySizesSelectionDelegate {
    
    // ______________________________________________________
    
    // MARK: Class properties
    
    // Default user profile is female
    var mySize:PoqMySize?
    
    // Cell attributes
    var mySizeCellIdentifier = "mySizeCategoryCellIdentifier"
    var mySizeCellHeight = CGFloat(65)
    
    // View model for networking operations
    var viewModel:MySizesViewModel?
    
    var isUpdated = false
    
    var updateDelegate:MySizesCategoryDelegate?
    
    // ______________________________________________________
    
    // MARK: IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // ______________________________________________________
    
    // MARK: UI delegates
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Init view model for networking calls
        self.viewModel = MySizesViewModel(viewControllerDelegate: self)
        
        // Set back button and disable hamburger menu
        self.navigationItem.leftBarButtonItem = NavigationBarHelper.setupBackButton(self)
        self.navigationItem.rightBarButtonItem = nil
        
        // Set navigation title
        if let title = self.mySize?.title{
            self.navigationItem.titleView = NavigationBarHelper.setupTitleView(title, titleFont: AppTheme.sharedInstance.mySizesNavigationTitleFont)
        }
        
        // Hide empty cells
        self.tableView?.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView?.reloadData()
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if self.isUpdated {
            
            if let delegate = self.updateDelegate {
                
                delegate.updateSizes()
            }
        }
    }
    
    // ______________________________________________________
    
    // MARK: Table delegates
    
    
    // Set number of rows (data.count)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mySize!.mySizesCategories!.count
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
        
        // Set indicator
        cell?.createAccessoryView()
        
        // Get my size
        let mySizeCategory = self.mySize!.mySizesCategories![indexPath.row]
        let mySizeTitle = mySizeCategory.title!
        var selectedSize = AppLocalization.sharedInstance.mySizesNoSizeSelected
        
        // Find related size
        
        // Traverse size categories
        for mySize in mySizeCategory.mySizes! {
            
            if let selected = mySize.isSelected {
                
                if selected {
                    
                    if let size = mySize.size {
                        
                        selectedSize = size
                        break
                    }
                    
                }
            }
        }
        
        
        // Set mysize name
        cell?.textLabel?.text = mySizeTitle
        cell?.textLabel?.font = AppTheme.sharedInstance.mySizesSelectionNameLabelFont
        
        // Set mysize value
        cell?.detailTextLabel?.text = selectedSize
        
        // Set font with respect to data
        if selectedSize == AppLocalization.sharedInstance.mySizesNoSizeSelected {
            
            cell?.detailTextLabel?.font = AppTheme.sharedInstance.mySizesSelectionNameLabelFont
            cell?.detailTextLabel?.textColor = UIColor.gray
        }
        else {
            
            cell?.detailTextLabel?.font = AppTheme.sharedInstance.mySizesSelectionValueFont
            cell?.detailTextLabel?.textColor = UIColor.black
        }
        
        return cell!
    }
    
    // Set cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return self.mySizeCellHeight
    }
    
    // Listen item selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let mySizesSelectionViewController:MySizesSelectionViewController = MySizesSelectionViewController(nibName: "MySizesSelectionView", bundle: nil)
        mySizesSelectionViewController.selectionDelegate = self
        let mySizeCategory = self.mySize!.mySizesCategories![indexPath.row]
        let selectedMySize = PoqMySize()
        selectedMySize.mySizesCategories = self.mySize?.mySizesCategories
        selectedMySize.title = mySizeCategory.title!
        mySizesSelectionViewController.mySize = selectedMySize
        mySizesSelectionViewController.mySizeType = selectedMySize.title == MySizeType.BACK.rawValue ? MySizeType.BACK : MySizeType.CUP
        self.navigationController?.pushViewController(mySizesSelectionViewController, animated: true)
        
        // Dismiss the selection
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // ______________________________________________________
    
    // MARK: Network delegates
    
    override func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        // Reset data and hide table (hides empty cells)
        self.mySize!.mySizesCategories! = []
        self.tableView?.reloadData()
    }
    
    override func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        if networkTaskType == PoqNetworkTaskType.getMySizes {
            
            // Reload table with new data
            for mySize in self.viewModel!.mySizes {
                
                if mySize.title! == MySizeTitles.BRAS.rawValue {
                    
                    self.mySize = mySize
                    break
                }
            }
            
            self.tableView?.reloadData()
        }
        else if networkTaskType == PoqNetworkTaskType.postMySizes {
            
            // Get updated results
            self.viewModel?.getMySizes(true)
        }
    }
    
    override func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        
        
    }
    
    // ______________________________________________________
    
    // MARK: Utilities
    
    // Delegate call after size selected
    func mySizeSelected(_ sizeId:String) {

        self.viewModel?.setMySize(sizeId)
        self.isUpdated = true
    }
    


}
