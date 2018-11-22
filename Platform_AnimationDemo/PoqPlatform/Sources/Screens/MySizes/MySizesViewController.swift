//
//  MySizesViewController.swift
//  Poq.iOS
//
//  Shows user's saved sizes
//
//  Created by Mahmut Canga on 07/04/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqNetworking
import UIKit

// MySize type is static in db and not cms driven
public enum MySizeType : String {
    
    case WOMAN = "Womens"
    case MAN = "Mens"
    case KID = "Kids"
    case BACK = "Back Size"
    case CUP = "Cup Size"
}

// MySize titles is static in db and not cms driven
public enum MySizeTitles : String {
    
    case TOPS = "Tops"
    case BOTTOMS = "Bottoms"
    case SHOES = "Shoes"
    case BRAS = "Bras"
}


class MySizesViewController: PoqBaseViewController, UITableViewDelegate, UITableViewDataSource, MySizesSelectionDelegate, MySizesCategoryDelegate {
    
    // ______________________________________________________
    
    // MARK: Class properties
    
    // Default user profile is female
    var mySizeType:MySizeType = MySizeType.WOMAN
    
    // Cell attributes
    var mySizeCellIdentifier = "mySizeCellIdentifier"
    var mySizeCellHeight:CGFloat = 65.0
    
    // View model for networking operations
    var viewModel:MySizesViewModel?
    
    // ______________________________________________________
    
    // MARK: IBOutlets
    
    @IBOutlet weak var bannerImage: PoqAsyncImageView!
    @IBOutlet weak var bannerTitleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bannerHeaderHeightConstraint: NSLayoutConstraint!
    
    
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
        var title:String
        
        // Decide view title via gender info
        if let gender = LoginHelper.getAccounDetails()?.gender {
            
            if gender == GenderType.F.rawValue {
                
                if self.mySizeType == MySizeType.MAN {
                    
                    // User is female then man size selection becomes 'His sizes'
                    title = AppLocalization.sharedInstance.mySizesHisSizesNavigationTitle
                    
                    // Track opposite gender size selection
                    PoqTrackerHelper.trackSetSizeForOpposite(PoqTrackerActionType.Female, label: PoqTrackerLabelType.HisSizes)
                }
                else if self.mySizeType == MySizeType.WOMAN {
                    
                    // User is female then woman size selection becomes 'My sizes'
                    title = AppLocalization.sharedInstance.mySizesMySizesNavigationTitle
                }
                else {
                    
                    // User is female then kids size selection becomes 'Little one's sizes'
                    title = AppLocalization.sharedInstance.mySizesLittleOneSizesNavigationTitle
                }
            }
            else {
                
                if self.mySizeType == MySizeType.MAN {
                    
                    // User is male then man size selection becomes 'My sizes'
                    title = AppLocalization.sharedInstance.mySizesMySizesNavigationTitle
                }
                else if self.mySizeType == MySizeType.WOMAN {
                    
                    // User is male then woman size selection becomes 'Her sizes'
                    title = AppLocalization.sharedInstance.mySizesHerSizesNavigationTitle
                    
                    // Track opposite gender size selection
                    PoqTrackerHelper.trackSetSizeForOpposite(PoqTrackerActionType.Male, label: PoqTrackerLabelType.HerSizes)

                }
                else {
                    
                    // User is male then kids size selection becomes 'Little one's sizes'
                    title = AppLocalization.sharedInstance.mySizesLittleOneSizesNavigationTitle
                }
            }
        }
        else {
            
            // Gender is unknown
            // Use generic titles
            
            if self.mySizeType == MySizeType.MAN {
                
                // Man's sizes
                title = AppLocalization.sharedInstance.mySizesManSizesNavigationTitle
            }
            else if self.mySizeType == MySizeType.WOMAN {
                
                // Woman's sizes
                title = AppLocalization.sharedInstance.mySizesWomanSizesNavigationTitle
            }
            else {
                
                // Kids's sizes
                title = AppLocalization.sharedInstance.mySizesKidsSizesNavigationTitle
                
            }
        }
        
        self.navigationItem.titleView = NavigationBarHelper.setupTitleView(title, titleFont: AppTheme.sharedInstance.mySizesNavigationTitleFont)
        
        // Load banner
        let bannerImageURL = DeviceType.IS_IPAD ? AppSettings.sharedInstance.iPadMySizesBannerUrl : AppSettings.sharedInstance.mySizesBannerUrl
        bannerImage?.getImageFromURL(URL(string:bannerImageURL)!, isAnimated: false)
        
        if DeviceType.IS_IPAD{
            bannerHeaderHeightConstraint.constant = 300.0
        }
        
        // Set banner title/description fonts
        self.bannerTitleLabel?.font = AppTheme.sharedInstance.mySizesBannerTitleFont
        self.bannerTitleLabel?.text = AppLocalization.sharedInstance.mySizesBannerTitle
        
        // Load my sizes
        self.viewModel!.getMySizes()
        
        // Hide empty cells
        self.tableView?.tableFooterView = UIView(frame: CGRect.zero)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    // ______________________________________________________
    
    // MARK: Table delegates

    
    // Set number of rows (data.count)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel!.mySizes.count
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
        let mySize = self.viewModel!.mySizes[indexPath.row]
        let mySizeTitle = mySize.title != nil ? mySize.title! : ""
        var selectedSize = AppLocalization.sharedInstance.mySizesNoSizeSelected
        
        // Find related size
        
        if let mySizeCategories = mySize.mySizesCategories {
            
            // Traverse size categories
            for mySizeCategory in mySizeCategories {
                
                // Find the size title of the cell, i.e. Womens
                if let mySizeCategoryTitle = mySizeCategory.title {
                    
                    if mySizeCategoryTitle == self.mySizeType.rawValue {
                        
                        // Traverse my sizes data until isSelected found for a size
                        if let mySizes = mySizeCategory.mySizes {
                            
                            for mySize in mySizes {
                                
                                if let selected = mySize.isSelected {
                                    
                                    if selected {
                                        
                                        if let size = mySize.size {
                                            
                                            selectedSize = size
                                            break
                                        }
                                        
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        
        // Set mysize name
        cell?.textLabel?.text = mySizeTitle
        cell?.textLabel?.font = AppTheme.sharedInstance.mySizesSelectionNameLabelFont
        
        // Set mysize value
        cell?.detailTextLabel?.text = selectedSize
        cell?.detailTextLabel?.font = AppTheme.sharedInstance.mySizesSelectedSizeLabelFont
        
        if mySizeTitle == MySizeTitles.BRAS.rawValue && self.mySizeType == MySizeType.WOMAN {
            
            // Show selected sizes for bras
            if let mySizeCategories = mySize.mySizesCategories {
                
                selectedSize = ""
                // Traverse size categories
                for mySizeCategory in mySizeCategories {
                    
                    // Traverse my sizes data until isSelected found for a size
                    if let mySizes = mySizeCategory.mySizes {
                        
                        for mySize in mySizes {
                            
                            if let selected = mySize.isSelected {
                                
                                if selected {
                                    
                                    if let size = mySize.size {
                                        
                                        selectedSize += size
                                        
                                        if let mySizeCategoryTitle = mySizeCategory.title  {
                                            
                                            if mySizeCategoryTitle == MySizeType.BACK.rawValue {
                                                
                                                selectedSize += ", "
                                            }
                                        }
                                    }
                                    
                                }
                            }
                        }
                    }
                }
                
                // This effects font and text color
                selectedSize = selectedSize.isEmpty ? AppLocalization.sharedInstance.mySizesNoSizeSelected : selectedSize
                cell?.detailTextLabel?.text = selectedSize
                cell?.detailTextLabel?.font = AppTheme.sharedInstance.mySizesSelectionNameLabelFont
            }
            
        }
        
        if mySizeTitle == MySizeTitles.BRAS.rawValue && self.mySizeType != MySizeType.WOMAN {
            
            // Hide Bras for the man/kid size selections
            cell!.isHidden = true
        }
        
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
        
        // Hide Bras for the male/kid size selections
        let mySize = self.viewModel!.mySizes[indexPath.row]
        
        if let title = mySize.title {
            
            if self.mySizeType != MySizeType.WOMAN && title == MySizeTitles.BRAS.rawValue {
                
                return CGFloat(0)
            }
            else {
                
                return self.mySizeCellHeight
            }
        }
        else {
            
            return self.mySizeCellHeight
        }
    }
    
    // Listen item selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let mySize = self.viewModel!.mySizes[indexPath.row]
        
        if let title = mySize.title {
            
            if  title == MySizeTitles.BRAS.rawValue {
                
                let mySizesCategoryViewController:MySizesCategoryViewController = MySizesCategoryViewController(nibName: "MySizesCategoryView", bundle: nil)
                mySizesCategoryViewController.updateDelegate = self
                mySizesCategoryViewController.mySize = self.viewModel!.mySizes[indexPath.row]
                self.navigationController?.pushViewController(mySizesCategoryViewController, animated: true)

            }
            else {
                
                let mySizesSelectionViewController:MySizesSelectionViewController = MySizesSelectionViewController(nibName: "MySizesSelectionView", bundle: nil)
                mySizesSelectionViewController.selectionDelegate = self
                mySizesSelectionViewController.mySize = self.viewModel!.mySizes[indexPath.row]
                mySizesSelectionViewController.mySizeType = self.mySizeType
                self.navigationController?.pushViewController(mySizesSelectionViewController, animated: true)
                
            }

        }
        
        
        // Dismiss the selection
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // ______________________________________________________
    
    // MARK: Network delegates
    
    override func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        // Reset data and hide table (hides empty cells)
        self.viewModel?.mySizes = []
        self.tableView?.reloadData()
    }
    
    override func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        if networkTaskType == PoqNetworkTaskType.getMySizes {
            
            // Reload table with new data
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
    }
    
    // Delegate call from size category
    func updateSizes() {
        
        self.viewModel?.getMySizes(true)
    }
    

}
