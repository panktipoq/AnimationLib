//
//  Common.swift
//  Poq.iOS
//
//  Created by Jun Seki on 26/02/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import UIKit

//MARK: - OS VERIONS

public func SYSTEM_VERSION_EQUAL_TO(_ version: NSString) -> Bool {
    return UIDevice.current.systemVersion.compare(version as String,
        options: NSString.CompareOptions.numeric) == ComparisonResult.orderedSame
}

public func SYSTEM_VERSION_GREATER_THAN(_ version: NSString) -> Bool {
    return UIDevice.current.systemVersion.compare(version as String,
        options: NSString.CompareOptions.numeric) == ComparisonResult.orderedDescending
}

public func SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(_ version: NSString) -> Bool {
    return UIDevice.current.systemVersion.compare(version as String,
        options: NSString.CompareOptions.numeric) != ComparisonResult.orderedAscending
}

public func SYSTEM_VERSION_LESS_THAN(_ version: NSString) -> Bool {
    return UIDevice.current.systemVersion.compare(version as String,
        options: NSString.CompareOptions.numeric) == ComparisonResult.orderedAscending
}

public func SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(_ version: NSString) -> Bool {
    return UIDevice.current.systemVersion.compare(version as String,
        options: NSString.CompareOptions.numeric) != ComparisonResult.orderedDescending
}

public func heightForView(_ text: String?, font: UIFont, width: CGFloat) -> CGFloat {
    let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
    label.numberOfLines = 0
    label.lineBreakMode = NSLineBreakMode.byWordWrapping
    label.font = font
    label.text = text

    label.sizeToFit()
    return label.frame.height + 25
}

public struct ScreenSize {
    static let SCREEN_WIDTH = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

public struct DeviceType {
    public static let IS_IPHONE_4_OR_LESS =  UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    public static let IS_IPHONE_5 = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    public static let IS_IPHONE_6_OR_LESS = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH <= 667.0
    public static let IS_IPHONE_6 = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    public static let IS_IPHONE_6P = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    public static let IS_IPHONE_X = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 812
    public static let IS_IPAD = UIDevice.current.userInterfaceIdiom == .pad
}
