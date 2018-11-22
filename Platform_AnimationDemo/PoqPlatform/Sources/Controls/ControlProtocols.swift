//
//  ControlProtocols.swift
//  Poq.iOS.Missguided
//
//  Created by Doug Dickinson on 28/04/2017.
//
//

public protocol BadgedControl: AnyObject {
    var badgeNumber: String { get set }
    func setBadgeNumber(_ badgeNumber: String, animated: Bool)
    func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControlEvents)
}

public protocol BarButtonItemProvider {
    func createBarButtonitem() -> UIBarButtonItem?
}
