//
//  VisualSearchGalleryDelegate.swift
//  PoqPlatform
//
//  Created by Manuel Marcos Regalado on 01/03/2018.
//

import Foundation

/// These errors will be used to return meaningful feedback to the completion closures and flow of calls
///
/// - galleryPermissionError: The user has not given access the the gallery
/// - unknownError: Unknown error
public enum GalleryError: Swift.Error {
    case galleryPermissionError
    case galleryNoImagesError
    case unknownError
}
/**
 `VisualSearchGalleryDelegate` defines the design that a Gallery controller should follow. These are the functions that a controller should implement in order to support the gallery actions
 
 This delegate should always return its completion blocks from the main thread. It handles itself the expensive operations by dispatching them in an async queue
 */
public protocol VisualSearchGalleryDelegate: AnyObject {
    
    /// This method will hold any setup needed for the controller to fetch gallery photos
    func setupPhotoGalleryController()
    
    /// Retrieves the last picture of the gallery
    ///
    /// - Parameters:
    ///   - targetSize: The given desired size for the image requested
    ///   - completion: It will return the desired image or nil and an error
    func galleryThumbnail(size targetSize: CGSize, completion: @escaping (UIImage?, GalleryError?) -> Void)
    
    /// This function will try to open the gallery by using a UIImagePickerController. This will only succeed if permissions are granted, otherwise, it will return an error back.
    ///
    /// - Parameters:
    ///   - controller: This controller needs to implement the protocols UINavigationControllerDelegate and UIImagePickerControllerDelegate so it can be the delegate of the gallery picker UIImagePickerController
    ///   - completion: This is the completion handler that will return an error if permissions are not granted or nil if the UIImagePickerController was presented
    func openGallery<T: UIViewController>(fromViewController controller: T, completion: @escaping (GalleryError?) -> Void) where T: UINavigationControllerDelegate, T: UIImagePickerControllerDelegate
}
