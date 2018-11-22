//
//  CurrencySwitcherViewController.swift
//  Poq.iOS.Platform
//
//  Created by Andrei Mirzac on 09/05/2018.
//

import UIKit
import PoqUtilities
import PoqModuling

/// Enum that defines available TableView sections.
public enum CurrencySection: Int {
    case selectedCurrency = 0
    case availableCurrencies
    
    // TODO: Change to internal enum count property when migrating to Swift 4.2
    static let allValues = [selectedCurrency, availableCurrencies]
}

open class CurrencySwitcherViewController: PoqBaseViewController, CurrencySwitcherPresenter {
    
    @IBOutlet open weak var tableView: UITableView? {
        didSet {
            tableView?.delegate = self
            tableView?.dataSource = self
            tableView?.separatorInset = .zero
            tableView?.rowHeight = UITableViewAutomaticDimension
            tableView?.sectionFooterHeight = 0
            tableView?.tableHeaderView = shouldShowTableViewHeader ? tableViewHeader : nil
            
        }
    }
    
    public var tableViewHeader: UIView? {
        let header: CurrencySwitcherHeaderView? = NibInjectionResolver.loadViewFromNib()
        header?.titleLabel?.textAlignment = .center
        header?.titleLabel?.text = "CURRENCY_SWITCHER_HEADER_TITLE".localizedPoqString
        return header
    }
    
    public var shouldShowTableViewHeader: Bool = false
    
    open var currencyCellType: UITableViewCell.Type = CurrencySwitcherCell.self
    
    open lazy var service: CurrencySwitcherService = {
        let service = CurrencySwitcherViewModel()
        service.presenter = self
        return service
    }()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setCellRegistration()
        setUpNavigationBar()
        service.generateContent()
        tableView?.reloadData()
    }
    
    open func setCellRegistration() {
        tableView?.registerPoqCells(cellClasses: [currencyCellType])
    }
    
    open func setUpNavigationBar() {
        navigationItem.titleView = nil
        navigationItem.title = "CURRENCY_SWITCHER".localizedPoqString
        if service.isCurrencySelected {
            navigationItem.leftBarButtonItem = NavigationBarHelper.setupBackButton(self)
        }
    }
    
    open func didTapCountry(atIndexPath: IndexPath) {
        guard let currency = service.content[.availableCurrencies]?[atIndexPath.row] else {
            Log.error("Selected cell indexPath doesn't match any country")
            return
        }
        
        guard service.isCurrencySelected else {
            saveCurrencyAndRestartApp(currency: currency)
            return
        }
        
        confirmSaveCurrency {
            self.saveCurrencyAndRestartApp(currency: currency)
        }
    }
    
    private func saveCurrencyAndRestartApp(currency: Currency) {
        CurrencySwitcherViewModel.saveSelectedCurrency(currency)
        PoqPlatform.shared.resetApplication()
    }
    
    private func confirmSaveCurrency(okAction: @escaping () -> Void) {
        let alert = UIAlertController(title: "COUNTRY_SELECTION_WARNING_TITLE".localizedPoqString, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "CANCEL".localizedPoqString, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK".localizedPoqString, style: .default, handler: { _ in
            okAction()
        }))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataDelegate
extension CurrencySwitcherViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let section = CurrencySection(rawValue: indexPath.section),
            section != .selectedCurrency else {
                return
        }
        didTapCountry(atIndexPath: indexPath)
    }
}

// MARK: - UITableViewDataSource
extension CurrencySwitcherViewController: UITableViewDataSource {
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: currencyCellType.poqReuseIdentifier, for: indexPath)
        if let section = CurrencySection(rawValue: indexPath.section), let currencies = service.content[section] {
            
            if case .selectedCurrency = section {
                cell.selectionStyle = .none
            }
            
            guard let cell = cell as? CurrencySwitcherView else {
                Log.error("Couldn't cast cell to CurrencySwitcherView")
                return UITableViewCell()
            }
            cell.setup(currency: currencies[indexPath.row])
        }
        return cell
    }
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return CurrencySection.allValues.count
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let currencySection = CurrencySection(rawValue: section), let currencies = service.content[currencySection] else {
            return 0
        }
        
        return currencies.count
    }
    
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard service.isCurrencySelected else {
            return nil
        }
        
        guard let currencySection = CurrencySection(rawValue: section), let _ = service.content[currencySection] else {
            Log.error("Missing Header View for Currencies Screen")
            return nil
        }
        
        let header: CurrencySwitcherSectionHeaderView? = NibInjectionResolver.loadViewFromNib()
        switch currencySection {
        case .availableCurrencies:
            header?.titleLabel?.text = "CURRENCY_SWITCHER_COUNTRIES_SECTION_TITLE".localizedPoqString
        case .selectedCurrency:
            header?.titleLabel?.text = "CURRENCY_SWITCHER_SELECTED_COUNTRY_SECTION_TITLE".localizedPoqString
        }
        return header
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return service.isCurrencySelected ? UITableViewAutomaticDimension : 0
    }
}
