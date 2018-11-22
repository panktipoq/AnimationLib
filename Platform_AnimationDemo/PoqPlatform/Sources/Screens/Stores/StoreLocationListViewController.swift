//
//  StoreLocationListViewController.swift
//  Poq.iOS
// GET THE STORES BASED ON YOUR LOCATION
//  Created by Barrett Breshears on 17/2/15.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import CoreLocation
import PoqNetworking
import PoqUtilities
import UIKit

open class StoreLocationListViewController: PoqBaseViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet open weak var locationTable: UITableView?
    
    open var delegate: StoreListDelegate?
    open lazy var viewModel: StoresViewModel = { return StoresViewModel(viewControllerDelegate: self) }()
    public let locationManager = CLLocationManager()
    open var currentLocation: CLLocationCoordinate2D?
    open var isRefresh: Bool = false
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.

        locationTable?.registerPoqCells(cellClasses: [StoreTableViewCell.self])
        locationTable?.estimatedRowHeight = CGFloat(AppSettings.sharedInstance.storeTableViewCellHeight)
        locationTable?.rowHeight = UITableViewAutomaticDimension
        
        //Pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor=AppTheme.sharedInstance.mainColor
        refreshControl.addTarget(self, action: #selector(StoreLocationListViewController.startRefresh(_:)), for: UIControlEvents.valueChanged)
        locationTable?.addSubview(refreshControl)
        
        loadStores()
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    open func loadStores(_ isRefresh: Bool = false) {
        // check if user allows gps and sort the stores by location
        if (CLLocationManager.locationServicesEnabled()) {
            self.isRefresh = isRefresh
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            // iOS 7 compatibility
            if locationManager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization)) {
                locationManager.requestWhenInUseAuthorization()
            }
            locationManager.startUpdatingLocation()
        } else {
            print("Location services are not enabled")
            //get default stores
            self.viewModel.getStores(isRefresh)
        }
    }
    
    @objc func startRefresh(_ refreshControl: UIRefreshControl) {
        
        loadStores(true)
        refreshControl.endRefreshing()
        
    }
    
    open func updatingLocation() {
        if let location: CLLocationCoordinate2D = currentLocation {
            self.viewModel.setStoresDistance(location)
            self.viewModel.sortByDistance()
        }
        self.locationTable?.reloadData()
    }
    
    // MARK: - network tasks
    override open func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    override open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        if networkTaskType == PoqNetworkTaskType.stores {
            
           updatingLocation()
        }
        
    }
    
    override open func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        
    }
    
    // MARK: - CoreLocation Delegate Methods
    open func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        Log.debug(error.localizedDescription)
        viewModel.getStores()
    }
    
    open func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        
        let locationArray = locations as NSArray
        guard let locationObj = locationArray.lastObject as? CLLocation else {
            return
        }

        let coord = locationObj.coordinate
        
        currentLocation = CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
        
        viewModel.stores.count == 0 ? viewModel.getStores(self.isRefresh) : updatingLocation()
    }
    
    // MARK: - Table view data source
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.stores.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: StoreTableViewCell = tableView.dequeueReusablePoqCell(forIndexPath: indexPath)
        
        cell.setUpStore(viewModel.stores[indexPath.row])
        return cell
        
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let store: PoqStore = viewModel.stores[indexPath.row]
        
        delegate?.storeSelected(store)
        
        //dismiss the selection
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
