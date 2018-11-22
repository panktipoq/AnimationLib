//
//  PermissionHelper.swift
//  Poq.iOS
//
//  Created by Barrett Breshears on 5/7/15.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import AVFoundation
import Contacts
import CoreLocation
import PoqUtilities
import Photos
import UIKit

public class PermissionHelper: NSObject {
    
    // Check if the user has allowed access to device's camera
    public static func checkCameraAccess(_ checkCompleted: @escaping (_ success: Bool) -> Void ) {
        
        let status: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        
        switch status {
        case .authorized:
            checkCompleted(true)
            
        case .denied, .restricted:
            checkCompleted(false)
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: checkCompleted)
        }
    }
    
    // Check if the user has allowed access of gallery
    
    public static func checkGalleryAccess(shouldRequestAccess requestAccess: Bool = false, _ checkCompleted: @escaping (_ success: Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .authorized:
            checkCompleted(true)
            
        case .denied, .restricted :
            checkCompleted(false)
            
        case .notDetermined:
            if requestAccess {
                PHPhotoLibrary.requestAuthorization({
                    checkCompleted($0 == .authorized)
                })
            } else {
                checkCompleted(false)
            }
        }
    }
    
    // Check if the user has allowed access of device location

    public static func checkLocationAccess() -> Bool? {

        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            return true
            
        case .notDetermined:
            return nil
            
        default:
            return false
        }
    }

    public static func checkBookContactAccess(_ checkCompleted: @escaping (_ success: Bool) -> Void) {

        let autorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        
        guard autorizationStatus != .denied else {
            checkCompleted(false)
            return
        }
        
        let contactStore = CNContactStore()
        contactStore.requestAccess(for: .contacts, completionHandler: { (granted: Bool, error: Error?) in
            if let error = error {
                Log.error("Contacts access request error: \(error)")
            }
            checkCompleted(granted)
        })
    }
}
