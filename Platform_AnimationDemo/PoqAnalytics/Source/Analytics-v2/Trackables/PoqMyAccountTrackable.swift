//
//  PoqMyAccountTrackable.swift
//  PoqPlatform
//
//  Created by Manuel Marcos Regalado on 09/11/2017.
//

import Foundation

public protocol PoqMyAccountTrackable {
    func signUp(userId: String, marketingOptIn: Bool, dataOptIn: Bool)
    func login(userId: String)
    func logout(userId: String)
    func addressBook(action: String, userId: String)
    func editDetails(userId: String)
    func switchCountry(countryCode: String)
}

extension PoqMyAccountTrackable where Self: PoqAdvancedTrackable {
    
    public func signUp(userId: String, marketingOptIn: Bool, dataOptIn: Bool){
        let signUpInfo: [String: Any] = [TrackingInfo.userId: userId, TrackingInfo.marketingOptIn: marketingOptIn, TrackingInfo.dataOptIn: dataOptIn]
        logEvent(TrackingEvents.MyAccount.signUp, params: signUpInfo)
    }
    
    public func login(userId: String) {
        let loginInfo: [String: Any] = [TrackingInfo.userId: userId]
        logEvent(TrackingEvents.MyAccount.login, params: loginInfo)
    }
    
    public func logout(userId: String) {
        let logoutInfo: [String: Any] = [TrackingInfo.userId: userId]
        logEvent(TrackingEvents.MyAccount.logout, params: logoutInfo)
    }

    public func addressBook(action: String, userId: String) {
        let parameters: [String: Any] = [TrackingInfo.action: action, TrackingInfo.userId: userId]
        logEvent(TrackingEvents.MyAccount.addressBook, params: parameters)
    }
    
    public func editDetails(userId: String) {
        let parameters: [String: Any] = [TrackingInfo.userId: userId]
        logEvent(TrackingEvents.MyAccount.editDetails, params: parameters)
    }
    
    public func switchCountry(countryCode: String) {
        let parameters: [String: Any] = [TrackingInfo.countryCode: countryCode]
        logEvent(TrackingEvents.MyAccount.switchCountry, params: parameters)
    }
}
