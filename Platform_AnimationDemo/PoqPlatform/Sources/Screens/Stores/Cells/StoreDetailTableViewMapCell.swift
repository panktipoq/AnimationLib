//
//  StoreDetailTableViewMapCell.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 17/08/2015.
//  Copyright (c) 2015 Poq. All rights reserved.
//

import Foundation
import MapKit
import PoqNetworking

open class StoreDetailTableViewMapCell: UITableViewCell {
    
    // MARK: - Class attributes
    // _____________________________
    
    // Custom view XIB, Identifier and custom height

    static let CellXib: String = "StoreDetailTableViewMapCellView"
    public static var CellHeight: CGFloat {
        
        // Map's height is variant depending on screen size
        get {
            
            if DeviceType.IS_IPHONE_6_OR_LESS {
                
                return CGFloat(AppSettings.sharedInstance.storeDetailMapCellHeightShort)
            } else if DeviceType.IS_IPAD {
                
                return CGFloat(AppSettings.sharedInstance.iPadStoreDetailMapCellHeight)
            } else {
                
                return CGFloat(AppSettings.sharedInstance.storeDetailMapCellHeight)
            }
        }
    }

    // MARK: - IBOutlets
    // _____________________________
    
    @IBOutlet weak var map: MKMapView? {        
        didSet {
            // According to below task, user interaction is disabled
            // https://app.asana.com/0/7963394747994/34574445544093
            map?.isZoomEnabled = false
            map?.isScrollEnabled = false
            map?.isUserInteractionEnabled = false
            map?.delegate = self
        }
    }
    
    // MARK: - UI Business Logic
    // _____________________________
    
    func addStoreLocationPointOnMap(_ store: PoqStore) {
        
        if let lat = store.latitude, let long = store.longitude {
            
            // Switf's lat.toDouble doesn't work well for minus values i.e. -0.14
            let latValue: Double = (lat as NSString).doubleValue
            let longValue: Double = (long as NSString).doubleValue
            
            // Create 2D location for the store coordinates
            let storeLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latValue, longValue)
            
            // Create point annotation for the store's 2D location
            let storePointAnnotation: MKPointAnnotation = MKPointAnnotation()
            storePointAnnotation.coordinate = storeLocation
            
            // Zoom in to dropped pin
            let span = MKCoordinateSpanMake(0.03, 0.03)
            let region = MKCoordinateRegion(center: storeLocation, span: span)
            
            map?.setRegion(region, animated: true)
            
            // Show the store coordinates on map
            map?.addAnnotation(storePointAnnotation)

        }
    }
}

extension StoreDetailTableViewMapCell: MKMapViewDelegate {
    
    open func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            // if annotation is not an MKPointAnnotation (eg. MKUserLocation),
            // return nil so map draws default view for it (eg. blue dot)...
            return nil
        }
        
        let popUp = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "marker")
        popUp.markerTintColor = AppTheme.sharedInstance.storeFinderPinColor
        popUp.canShowCallout = false
        return popUp
    }
}
