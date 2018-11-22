//
//  MyProfileAddressBookViewController.swift
//  Poq.iOS
//
//  Created by Antonia Chekrakchieva on 11/11/15.
//  Copyright © 2015 Poq. All rights reserved.
//

import PoqNetworking
import UIKit
import PoqAnalytics

public protocol NavigationBarTitle: AnyObject {
    
    // TODO: Please rename condition variable in this protocol and refactor the code accordingly. 
    // This will reduce WTH/Minute for reading this controller code
    func setUpNavigationBar(_ title: String, leftBarButtonItem: UIBarButtonItem, rightBarButtonItem: UIBarButtonItem?, isNavigationBarTitleEnabled: Bool)
}

extension NavigationBarTitle where Self: UIViewController {
    public func setUpNavigationBar(_ title: String, leftBarButtonItem: UIBarButtonItem, rightBarButtonItem: UIBarButtonItem? = nil, isNavigationBarTitleEnabled: Bool = AppSettings.sharedInstance.addressTypeTitleEnabled) {
        if !isNavigationBarTitleEnabled {
            navigationItem.titleView = NavigationBarHelper.setupTitleView(title)
        }
        navigationItem.leftBarButtonItem = leftBarButtonItem
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
}

open class MyProfileAddressBookViewController: PoqBaseViewController, NavigationBarTitle {

    open var viewModel: MyProfileAddressesViewModel = MyProfileAddressesViewModel()
    
    @IBOutlet open var userAddressesTableView: UITableView! {
        didSet {
            userAddressesTableView.registerPoqCells(cellClasses: [MyProfileAddressBookTitleTableViewCell.self, MyProfileAddressBookDetailsTableViewCell.self])
            userAddressesTableView.estimatedRowHeight = UITableViewAutomaticDimension
        }
    }

    @IBOutlet weak var errorMessageBig: UILabel! {
        didSet {
            errorMessageBig.isHidden = true
            errorMessageBig.font = AppTheme.sharedInstance.myProfileEmptyAddressBookBigMessageFont
            errorMessageBig.text = AppLocalization.sharedInstance.baseNoAddressMessage
            errorMessageBig.accessibilityIdentifier = AccessibilityLabels.baseNoAddressMessage
        }
    }
    
    @IBOutlet weak var errorMessageSmall: UILabel! {
        didSet {
            errorMessageSmall.isHidden = true
            errorMessageSmall.font = AppTheme.sharedInstance.myProfileEmptyAddressBookSmallMessageFont
            errorMessageSmall.text = AppLocalization.sharedInstance.moreInforNoAddressMessage
        }
    }
    
    @IBOutlet weak var errorIcon: UIImageView? {
        didSet {
            errorIcon?.isHidden = true
        }
    }
    
    @IBOutlet weak var errorDecorativeView: UIView? {
        didSet {
            errorDecorativeView?.isHidden = true
        }
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        viewModel.viewControllerDelegate = self
        
        let navigationBarTitle = AppLocalization.sharedInstance.myProfileAddressBookTitle
        let navigationBarLeftItem = NavigationBarHelper.setupBackButton(self)
        
        // TODO: 
        // We are creating the right navbar item and giving a target which creates a reference. 
        // I'm not sure if this reference will be killed when the controller is removed from view hierarchy
        // Because if AppSettings.sharedInstance.isMyProfileAddNewAddressEnabled is false, we are not using this instance
        // We should avoid creating Strong Reference Cycles Between Class Instances
        var navigationBarRightItem: UIBarButtonItem
        if AppSettings.sharedInstance.myProfileAddressSystemTopRightButton {
            navigationBarRightItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
            navigationBarRightItem.tintColor = AppTheme.sharedInstance.naviBarItemColor
        } else {
            navigationBarRightItem = NavigationBarHelper.createButtonItem(withTitle: AppLocalization.sharedInstance.myProfileAddressBookAddButtonTitle, target: self, action: #selector(addButtonPressed))
        }
        
        if !AppSettings.sharedInstance.isMyProfileAddNewAddressEnabled {
            
            // Address list in Checkout flow conflicts with this
            // So I had to implement this cloud setting this way
            navigationBarRightItem = UIBarButtonItem()
            
        }
        
        setUpNavigationBar(navigationBarTitle, leftBarButtonItem: navigationBarLeftItem, rightBarButtonItem: navigationBarRightItem)
        setupPullToRefresh()

    }
    
    override open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        // Track Analytics
        trackAnalyticsEvent(networkTaskType)
        
        userAddressesTableView.reloadData()
        
        // Update Empty/Error state
        errorMessageBig.isHidden = !viewModel.isEmpty()
        errorMessageSmall.isHidden = !viewModel.isEmpty()
        errorIcon?.isHidden = !viewModel.isEmpty()
        errorDecorativeView?.isHidden = !viewModel.isEmpty()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getAddresses()
    }
    
    public func setupPullToRefresh() {
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = AppTheme.sharedInstance.mainColor
        refreshControl.addTarget(self, action: #selector(MyProfileAddressBookViewController.startCheckoutRefresh(_:)), for: UIControlEvents.valueChanged)
        userAddressesTableView.addSubview(refreshControl)
    }
    
    @objc func startCheckoutRefresh(_ refreshControl: UIRefreshControl) {
        
        viewModel.getAddresses()
        refreshControl.endRefreshing()
    }

    func viewAmendAddress(_ index: Int) {
        
        guard AppSettings.sharedInstance.isMyProfileEditAddressEnabled else {
            
            return
        }
        
        guard index < viewModel.addresses.count else {
            
            return
        }
        
        /// TODO: it looks like really bad workaroun... we creat checkout to add address in profile...
        let checkoutItem = PoqCheckoutItem<PoqBagItem>()
        checkoutItem.shippingAddress = viewModel.addresses[index]

        NavigationHelper.sharedInstance.loadAddAddress(AddressType.AddressBook, title: nil, checkoutAddressesProvider: checkoutItem)

    }
    
    public func trackAnalyticsEvent(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        if (networkTaskType == .deleteUserAddress) {
            // Track remove address
            PoqTrackerV2.shared.addressBook(action: AddressBookAction.remove.rawValue, userId: User.getUserId())
        }
    }
}

// MARK: - UITableViewDelegate Implementation
// __________________________

extension MyProfileAddressBookViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.hasTitle(indexPath) ? viewModel.getTitleHeigh() : viewModel.getRowHeight()
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.hasTitle(indexPath) ? viewModel.getTitleHeigh() : viewModel.getRowHeight()
        
    }
    
}

// MARK: - UITableViewDataSource Implementation
// __________________________

extension MyProfileAddressBookViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getNumberOfRows()
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return viewModel.getCellForRow(tableView, indexPath: indexPath, whiteButtonDelegate: self)
    }

    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if !AppSettings.sharedInstance.isMyProfileEditAddressEnabled {
            
            return false
        }
        
        return viewModel.canEdit(indexPath)
    }
    
    open func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            let alert = UIAlertController(title: AppLocalization.sharedInstance.deletePopupMessage, message: "", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "No", style: .default) {
                (action: UIAlertAction) -> Void in
                }
            )
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default) {
                (action: UIAlertAction) -> Void in
                    self.viewModel.deleteAddress(indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            )
            present(alert, animated: true, completion: nil)
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewAmendAddress(indexPath.row)
    }
}

// MARK: - WhiteButton Delegate
// __________________________
extension MyProfileAddressBookViewController: WhiteButtonDelegate {
    
    public func whiteButtonClicked(_ sender: Any?) {
        guard let button = sender as? WhiteButton else {
            return
        }
        viewAmendAddress(button.tag)
    }
}

// MARK: - Add button pressed
// __________________________
extension MyProfileAddressBookViewController {
    
    @objc func addButtonPressed() {
        // have to do it with separate string to satisfy generic func call
        NavigationHelper.sharedInstance.loadAddAddress(AddressType.NewAddress, title: nil)
        
    }
}
