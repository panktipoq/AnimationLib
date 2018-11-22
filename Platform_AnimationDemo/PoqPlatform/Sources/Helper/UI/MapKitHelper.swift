//
//  MapKitHelper.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 11/09/2015.
//  Copyright (c) 2015 Poq. All rights reserved.
//

import Foundation
import MapKit


open class MapKitHelper {
    
    public static func releaseMap(_ map: MKMapView) {
        
        map.delegate = nil
        map.mapType = MKMapType.satellite    // Changing maptype releases cached resources (bug in MKMaps)
        map.showsUserLocation = false
        map.layer.removeAllAnimations()
        map.removeAnnotations(map.annotations)
        map.removeFromSuperview()
    }
}
