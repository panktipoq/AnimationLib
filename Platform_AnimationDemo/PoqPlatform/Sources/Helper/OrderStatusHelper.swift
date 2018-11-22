//
//  OrderStatusHelper.swift
//  Poq.iOS
//
//  Created by Jun Seki on 28/04/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import UIKit
import Foundation


open class OrderStatusHelper: NSObject {
    
    open class func checkIfOrderStatusesContainsCurrentStatus(_ statuses: String, currentStatus: String?) -> Bool{
        
        guard let status = currentStatus else {
            return false
        }
        
        let statusesArray = statuses.lowercased().components(separatedBy: AppSettings.sharedInstance.orderStatusesSeperator)
        return statusesArray.contains(status.lowercased())
    }
    
    open class func checkOrderActioned(_ orderStatus:String) -> Bool{
        let statusesArray = AppSettings.sharedInstance.orderDarkGreenColorStatuses.components(separatedBy: AppSettings.sharedInstance.orderStatusesSeperator)
        return statusesArray.contains(orderStatus)
    }
    
    open class func setUpControls(_ orderStatus: String?, colorView: UIView?, label: UILabel?){
    
//        1. Placed: #FF0FBE
//        2. Despatched: #04CB3D
//        3. Partially Despatched: #C0DE39
//        4. Partially Returned: #FFCD0F
//        5. Fully returned: #D0021B
//        6. Despatched / Partially returned: #04CB3D
//        7. Despatched to Store: #04CB3D
//        8. Ready for collection: #04CB3D
//        9. Collected: #04CB3D
//        10. Refund issued, uncollected:  #D0021B
//        11. Refund issued, Arrived Damaged:  #D0021B
//        12. Refund issued, Out of stock:  #D0021B
//        13. Partially Despatched to Store: #C0DE39
//        14. Partially Refunded: #FFCD0F
//        15. Despatched to Store / Partially Refunded: #04CB3D
//        16. Collected / Partially Refunded: #04CB3D

        if OrderStatusHelper.checkIfOrderStatusesContainsCurrentStatus(AppSettings.sharedInstance.orderPinkColorStatuses, currentStatus: orderStatus) {
            
            colorView?.backgroundColor = AppTheme.sharedInstance.orderPinkColor
            label?.textColor = AppTheme.sharedInstance.orderPinkColor
            return
        }
        
        if OrderStatusHelper.checkIfOrderStatusesContainsCurrentStatus(AppSettings.sharedInstance.orderDarkGreenColorStatuses, currentStatus: orderStatus) {
            
            colorView?.backgroundColor = AppTheme.sharedInstance.orderDarkGreenColor
            label?.textColor = AppTheme.sharedInstance.orderDarkGreenColor
            return
        }
        
        if OrderStatusHelper.checkIfOrderStatusesContainsCurrentStatus(AppSettings.sharedInstance.orderLightGreenColorStatuses, currentStatus: orderStatus) {
            
            colorView?.backgroundColor = AppTheme.sharedInstance.orderLightGreenColor
            label?.textColor = AppTheme.sharedInstance.orderLightGreenColor
            return
        }
        
        if OrderStatusHelper.checkIfOrderStatusesContainsCurrentStatus(AppSettings.sharedInstance.orderYellowColorStatuses, currentStatus: orderStatus) {
            
            colorView?.backgroundColor = AppTheme.sharedInstance.orderYellowColor
            label?.textColor = AppTheme.sharedInstance.orderYellowColor
            return
        }
        
        if OrderStatusHelper.checkIfOrderStatusesContainsCurrentStatus(AppSettings.sharedInstance.orderRedColorStatuses, currentStatus: orderStatus) {
            
            colorView?.backgroundColor = AppTheme.sharedInstance.orderRedColor
            label?.textColor = AppTheme.sharedInstance.orderRedColor
            return

        }
        
        colorView?.backgroundColor = UIColor.gray
        label?.textColor = UIColor.gray
    }
}
