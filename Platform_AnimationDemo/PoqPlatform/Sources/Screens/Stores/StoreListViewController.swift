//
//  ShopListViewController.swift
//  Poq.iOS
//  STORES SORTED BY CITY
//  Created by Barrett Breshears on 17/2/15.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import CoreLocation
import PoqNetworking
import PoqUtilities
import UIKit

public protocol StoreListDelegate {
    
    func storeSelected(_ store: PoqStore)
    
}

open class StoreListViewController: PoqBaseViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet open weak var storeTable: UITableView?
    
    open lazy var viewModel: StoresViewModel = { return StoresViewModel(viewControllerDelegate: self) }()
    open var cityLetterStoresMap: [String: [PoqStore]] = [:]
    open var alphabet: [String] = [] // cities alphabet, lowcase first letters
    open var useAlphabetIndex: Bool = true
    
    open var delegate: StoreListDelegate?
    let locationManager: CLLocationManager = CLLocationManager()

    var currentLocation: CLLocationCoordinate2D?
    let cellHeight: CGFloat = CGFloat(AppSettings.sharedInstance.storeTableViewCellHeight)
    var isRefresh: Bool = false
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
       
        storeTable?.registerPoqCells(cellClasses: [StoreTableViewCell.self])
        
        //Pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor=AppTheme.sharedInstance.mainColor
        refreshControl.addTarget(self, action: #selector(StoreListViewController.startRefresh(_:)), for: UIControlEvents.valueChanged)
        storeTable?.addSubview(refreshControl)
        
        loadStores()
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func loadStores(_ isRefresh: Bool = false) {
        
        if (CLLocationManager.locationServicesEnabled()) {
            self.isRefresh = isRefresh
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            
            locationManager.requestWhenInUseAuthorization()

            locationManager.startUpdatingLocation()
        } else {
            Log.verbose("Location services are not enabled")
            //get default stores
            self.viewModel.getStores(isRefresh)
        }
    }
    
    @objc func startRefresh(_ refreshControl: UIRefreshControl) {
        
        loadStores(true)
        refreshControl.endRefreshing()
        
    }

    open func UpdatingLocation() {
        if currentLocation != nil {
            viewModel.setStoresDistance(currentLocation!)
        }
        storeTable?.reloadData()
    }
    
    // MARK: - network tasksa
    override open func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    override open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        if networkTaskType == PoqNetworkTaskType.stores {
            UpdatingLocation()
            
            // Log store list
            PoqTracker.sharedInstance.logAnalyticsEvent("Store List", action: "Count", label: String(viewModel.stores.count), extraParams:nil)
            
            (alphabet, cityLetterStoresMap) = viewModel.createCityStoresMap()
            
            storeTable?.reloadData()
        }
    }
    
    // MARK: - CoreLocation Delegate Methods
    open func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        Log.debug("error = \(error.localizedDescription)")
        viewModel.getStores(self.isRefresh)
    }
    
    open func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        
        let locationArray = locations as NSArray
        let locationObj = locationArray.lastObject as! CLLocation
        let coord = locationObj.coordinate
        
        currentLocation = CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
        viewModel.stores.count == 0 ? viewModel.getStores(self.isRefresh) : UpdatingLocation()
    }
    
    // MARK: - Table view data source
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return alphabet.count
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        let letter = alphabet[section]

        return cityLetterStoresMap[letter]?.count ?? 0
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let letter = alphabet[indexPath.section]
        var stores: [PoqStore] = cityLetterStoresMap[letter]!
        let store: PoqStore = stores[indexPath.row]

        let cell: StoreTableViewCell = tableView.dequeueReusablePoqCell(forIndexPath: indexPath)
        
        cell.setUpStore(store)
        
        return cell
        
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let letter = alphabet[indexPath.section] as String
        var stores: [PoqStore] = cityLetterStoresMap[letter]!
        let store: PoqStore = stores[indexPath.row]

        delegate?.storeSelected(store)
        
        //dismiss the selection
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    open func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return useAlphabetIndex ? alphabet : nil
    }
    
    open func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }

}
