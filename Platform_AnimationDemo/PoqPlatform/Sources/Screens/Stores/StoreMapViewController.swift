//
//  StoreMapViewController.swift
//  Poq.iOS
//
//  Created by Barrett Breshears on 17/2/15.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import CoreLocation
import MapKit
import PoqNetworking
import PoqUtilities
import UIKit

protocol StoresMapViewDelegate {
    
    func mapSwipeRight()
    
}

open class StoreMapViewController: PoqBaseViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    open var delegate: StoreListDelegate?
    lazy var viewModel: StoresViewModel = { return StoresViewModel(viewControllerDelegate: self) }()

    let locationManager = CLLocationManager()
    var coordinates: [CLLocationCoordinate2D] = []
    var annotations: [MKPointAnnotation] = []
    var userLocation: CLLocationCoordinate2D?
    var selectedStoreId: Int = 0
    var mapDelegate: StoresMapViewDelegate?
    
    @IBOutlet var mapView: MKMapView?
    @IBOutlet var swipeView: UIView?
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mapView?.delegate = self
        viewModel.getStores()
        dropPins()

        // add swipe guesture to allow swipe to the right to load stores list
        let swipeRight = UISwipeGestureRecognizer(target: self,
                                                  action: #selector(StoreMapViewController.swipeRight))
        
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        swipeView?.addGestureRecognizer(swipeRight)
        
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            
            userLocation = nil
            locationManager.startUpdatingLocation()
        } else {
            
            Log.debug("Location services are not enabled")
        }
        
    }
    
    func zoomInAroundUser() {
        
        guard let userLocation = userLocation else {
            return
        }
        
        let region = MKCoordinateRegionMakeWithDistance(userLocation,
                                                        AppSettings.sharedInstance.mapZoomInDistance,
                                                        AppSettings.sharedInstance.mapZoomInDistance)

        mapView?.setRegion(region,
                           animated: true)
    }
    
    // MARK: - Networking
    
    override open func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    override open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        if networkTaskType == PoqNetworkTaskType.stores {
            dropPins()
            zoomInAroundUser()
        }
        
    }
    
    override open func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        
    }
    
    // MARK: - CoreLocationDelegate
    
    open func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        locationManager.stopUpdatingLocation()
        Log.debug("error = \(error.localizedDescription)")
        
        viewModel.getStores()
    }
    
    open func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        locationManager.stopUpdatingLocation()

        if userLocation == nil {
            
            userLocation = locations.last?.coordinate
            zoomInAroundUser()
        }
    }
    
    // MARK: - MKMapViewDelegate
    
    open func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            // if annotation is not an MKPointAnnotation (eg. MKUserLocation),
            // return nil so map draws default view for it (eg. blue dot)...
            return nil
        }
        
        let rightButton = UIButton(type: UIButtonType.custom)
        // Button width hardcoded to fixed value because image can be too small to be fixed to it.
        let image = ImageInjectionResolver.loadImage(named: "Next")
        rightButton.setImage(image, for: UIControlState())
        rightButton.tag = 2
        
        let popUp = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "marker")
        popUp.markerTintColor = AppTheme.sharedInstance.storeFinderPinColor
        popUp.canShowCallout = true
        rightButton.frame = CGRect(x: 0.0, y: 0.0, width: 30.0, height: popUp.frame.size.height)
        popUp.rightCalloutAccessoryView = rightButton
        return popUp
    }
    
    open func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard let annotation: MKAnnotation = view.annotation else {
            Log.warning("view.annotation is nil, looks bad")
            return
        }
        
        Log.verbose("view.annotation.title \(String(describing: annotation.title))")
        
        guard let storeTitle = annotation.title,
            let storeAddress = annotation.subtitle else {
                
                return
        }
        
        for store in viewModel.stores {
            
            if (store.name == storeTitle) &&
                (store.address == storeAddress) {
                
                if let storeID = store.id {
                    
                    selectedStoreId = storeID
                    Log.verbose("selectedStoreId: \(selectedStoreId)")
                }
            }
        }
    }
    
    open func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control.tag == 2 {
            
            if selectedStoreId != 0 {
                
                for store in viewModel.stores {
                    
                    if let storeID = store.id,
                        storeID == selectedStoreId {
                        
                        delegate?.storeSelected(store)
                        break
                    }
                }
                
            }
            
        }
        
    }
    
    // MARK: - DropPins
    
    func dropPins() {
        
        OperationQueue().addOperation {
            
            self.annotations.removeAll()
            
            guard self.viewModel.stores.count > 0 else {
                
                return
            }
            
            for store in self.viewModel.stores {
                
                guard let latitude = store.latitude,
                    let longitude = store.longitude,
                    let lat = Double(latitude),
                    let long = Double(longitude) else {
                        
                        continue
                }
                
                let location = CLLocationCoordinate2DMake(lat,
                                                          long)
                
                // Drop a pin
                let dropPin = MKPointAnnotation()
                dropPin.coordinate = location
                dropPin.title = store.name
                dropPin.subtitle = store.address
                self.annotations.append(dropPin)
                self.coordinates.append(location)
            }
                        
            DispatchQueue.main.async {
                
                self.mapView?.addAnnotations(self.annotations)
            }
        }
    }
    
    @objc func swipeRight() {
        
        mapDelegate?.mapSwipeRight()
    }
}
