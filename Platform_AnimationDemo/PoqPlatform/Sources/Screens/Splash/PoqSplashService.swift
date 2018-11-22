//
//  PoqSplashService.swift
//  Poq.iOS.Platform
//
//  Created by Manuel Marcos Regalado on 07/08/2017.
//
//

import Foundation
import PoqModuling
import PoqNetworking
import PoqUtilities

public protocol PoqSplashService: PoqNetworkTaskDelegate {
    
    /// Variable that holds the loaded PoqSplash object
    var splash: PoqSplash? { get set }
    
    /// Variable to which the service will send the callbacks
    var presenter: PoqSplashPresenter? { get set }
    
    /// Send an API request for MightyBot settings
    func getSettings()
    
    /// Returns the value behind MightyBot setting `splashBackgroundColor`
    func getSplashBackgroundColorStyle() -> UIColor
    
    /// Setup Application (Tabs, Configs etc.)
    func setupApplication()
    
    /**
     Called on `networkTaskDidComplete(_:result:)` for type checks.
     
     - parameter networkTaskType: type of the executed network request listed in `PoqNetworkTaskType` enum
     - parameter result: an object conforming to `Mappable` protocol
     */
    func parseResponse(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?)
    
    /**
     Response parser of `getSettings()` API callback
     
     - parameter result: an object to be parsed
     */
    func parseSplash(_ result: [PoqSplash]?)
}

extension PoqSplashService {
    
    // ______________________________________________________
    
    // MARK: - Network Response Parser
    
    func getSettings() {
        PoqNetworkService(networkTaskDelegate: self).getSplash()
    }
    
    func parseSplash(_ result: [PoqSplash]?) {
        if let result = result, !result.isEmpty {
            splash = result[0]
            SettingParseHelper.updateAppSettingsWithSplashObject(result[0])
        }
        // Send back network request result to view controller
        presenter?.update(state: .completed, networkTaskType: PoqNetworkTaskType.splash)
    }
    
    func parseResponse(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        
        switch networkTaskType {
            
        case PoqNetworkTaskType.splash:
            parseSplash(result as? [PoqSplash])
            
        default:
            Log.error("Network task is not implemented:\(networkTaskType)")
        }
    }

    // ______________________________________________________
    
    // MARK: - Network Task Callbacks
    
    /**
     Callback before start of the async network task
     */
    func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        presenter?.update(state: .loading, networkTaskType: networkTaskType)
    }
    
    /**
     Callback after async network task is completed successfully
     */
    func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        
        parseResponse(networkTaskType, result: result)
    }
    
    /**
     Callback when task fails due to lack of responded data, connectivity etc.
     */
    func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        
        switch networkTaskType {
            
        case PoqNetworkTaskType.splash:
            SettingParseHelper.parseSettingsFromExistedDB(nil)
            setupApplication()
            
        default:
            Log.error("Network task is not implemented:\(networkTaskType)")
        }

        presenter?.update(state: .error, networkTaskType: networkTaskType, withNetworkError: error)
    }
}
