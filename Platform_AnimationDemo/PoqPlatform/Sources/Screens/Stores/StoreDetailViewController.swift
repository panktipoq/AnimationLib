//
//  StoreDetailViewController.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 11/08/2015.
//  Copyright (c) 2015 Poq. All rights reserved.
//

import Foundation
import MapKit
import PoqNetworking

open class StoreDetailViewController: PoqBaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Class Attributes
    //_____________________________________
    
    // Selected store id used in network call
    public final var selectedStoreId: Int = 0
    
    public final var selectedStoreTitle: String = ""
    
    // View Model (Init here to avoid optional)
    lazy open var viewModel: StoreDetailViewModel = {
        // Set delegation for updating UI
        let storeDetailViewModel = StoreDetailViewModel(viewControllerDelegate:self)
        return storeDetailViewModel
    }()
    
    public final var isRightNavigationItemSet: Bool = false
    
    final var mapCellDelegate: StoreDetailTableViewMapCell?
    
    // Only IBOutlet is tableView, the rest is custom cell implementation
    @IBOutlet open weak var tableView: UITableView!
    
    // MARK: - UIViewController Delegates
    //_____________________________________
    
    override open func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Setup UI specific parts
        setupNavigationBar()
        setupTableView()
        registerCells()
        
        //get init table width
        viewModel.cellWidth = tableView.bounds.width
        // Get store detail
        viewModel.getStoreDetail(selectedStoreId, isRefresh: false)
    }
    
    // MARK: - UI Specific Business Logic
    // ____________________________________
    
    open func setupDirectionsButtonOnNavigationBar() {
        
        if !isRightNavigationItemSet {
            
            let storeCoordinates: CLLocationCoordinate2D = viewModel.getStoreCLLocationCoordinate2D(viewModel.store)
            let isInValidStoreCoordinates: Bool = storeCoordinates.latitude == 0 && storeCoordinates.longitude == 0
            
            if !isInValidStoreCoordinates {
                
                let directionsButton = NavigationBarHelper.createButtonItem(withTitle: AppLocalization.sharedInstance.directionStoreText,
                                                                            target: self,
                                                                            action: #selector(StoreDetailViewController.directionsButtonClick),
                                                                            position: .right)
                
                navigationItem.setRightBarButton(directionsButton, animated: true)
                
                isRightNavigationItemSet = true
            }
        }
    }
    
    @objc open func directionsButtonClick() {
        
        viewModel.directionButtonClicked()
    }
    
    /**
    Setup navigation bar
    */
    open func setupNavigationBar() {
        
        //set up back button
        navigationItem.leftBarButtonItem = NavigationBarHelper.setupBackButton(self)
        navigationItem.rightBarButtonItem = nil
        
        if AppSettings.sharedInstance.storeDetailNameOnNavigationBar {
        //set up title
        navigationItem.titleView = NavigationBarHelper.setupTitleView(selectedStoreTitle, titleFont: AppTheme.sharedInstance.naviBarTitleFont, titleColor: AppTheme.sharedInstance.naviBarTitleColor)
        }
    }
    
    /**
    Setup tableView
    */
    open func setupTableView() {
        
        // Hide empty cells
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        // Remove table cell seperators
        tableView.separatorColor = UIColor.clear
    }
    
    /**
    Register tableView's custom cell implementations
    */
    open func registerCells() {
        
        tableView.registerPoqCells(cellClasses: [StoreDetailTableViewMapCell.self, StoreDetailTableViewCallCell.self, StoreDetailTableViewNameCell.self, StoreDetailTableViewHoursCell.self] )
    }
    
    // MARK: - UITableView Delegates
    //_____________________________________
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return viewModel.getTableCellHeightForRow(indexPath.row)
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return viewModel.content.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return viewModel.getTableCellForIndexPath(tableView, indexPath: indexPath)
    }
    
    // Disable row highlight
    open func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        
        return false
    }
    
    // MARK: - Network Delegates
    
    /**
    Called from view model when a network operation ends
    */
    override open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        setupDirectionsButtonOnNavigationBar()
        tableView.reloadData()
    }
    
    // MARK: - BackButton Delegate
    //_____________________________________
    
    open override func backButtonClicked() {
        
        if let map = mapCellDelegate?.map {
            
            MapKitHelper.releaseMap(map)
            mapCellDelegate?.map = nil
        }
        
        super.backButtonClicked()
    }
}
