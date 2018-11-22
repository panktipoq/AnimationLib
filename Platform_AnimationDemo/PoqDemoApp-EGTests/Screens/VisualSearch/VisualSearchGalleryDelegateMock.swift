//
//  VisualSearchGalleryDelegateMock.swift
//  PoqDemoApp-EGTests
//
//  Created by Manuel Marcos Regalado on 28/02/2018.
//

import UIKit
import AVFoundation

@testable import PoqPlatform

class VisualSearchGalleryDelegateMock: NSObject, VisualSearchGalleryDelegate {
    
    var galleryPermissionGranted: Bool = false

    init(galleryPermissionGranted: Bool) {
        self.galleryPermissionGranted = galleryPermissionGranted
    }
    
    public func setupPhotoGalleryController() {
        // This is method is to adhere protocol. It is defined by `VisualSearchGalleryDelegate`
    }
    
    public func galleryThumbnail(size targetSize: CGSize, completion: @escaping (_ image: UIImage?, _ error: GalleryError?) -> Void) {
        if galleryPermissionGranted {
            let image = UIImage()            
            completion(image, nil)
        } else {
            completion(nil, GalleryError.galleryPermissionError)
        }
    }
    
    func openGallery<T: UIViewController>(fromViewController controller: T, completion: @escaping (GalleryError?) -> Void) where T: UINavigationControllerDelegate, T: UIImagePickerControllerDelegate {
        if galleryPermissionGranted {
            completion(nil)
        } else {
            completion(GalleryError.galleryPermissionError)
        }
    }
}
