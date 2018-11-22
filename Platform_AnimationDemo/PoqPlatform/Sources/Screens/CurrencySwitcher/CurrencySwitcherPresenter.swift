//
//  CurrencySwitcherPresenter.swift
//  Poq.iOS.Platform
//
//  Created by Andrei Mirzac on 30/05/2018.
//

import Foundation

/// Defines design that currency switcher presentation should follow. Any View Controller wishing to implement currency switcher should implement this protocol.
public protocol CurrencySwitcherPresenter: class {
    
    /// Service used by presenter.
    var service: CurrencySwitcherService { get }
    /// Cell type to be used by tableview.
    var currencyCellType: UITableViewCell.Type { get }
    /// Decides if header needs be showed.
    var shouldShowTableViewHeader: Bool { get set }
    /// TableView header to show.
    var tableViewHeader: UIView? { get }
    /// Method called on country tap action.
    func didTapCountry(atIndexPath: IndexPath)
    
    /// Register cells.
    func setCellRegistration()
    
    /// Setup navigation bar.
    func setUpNavigationBar()
}
