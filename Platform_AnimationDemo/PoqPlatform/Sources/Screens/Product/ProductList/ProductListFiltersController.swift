//
//  ProductListFiltersController.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 29/01/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqNetworking
import PoqUtilities
import PoqAnalytics
import UIKit

/// In PoqFilter, all except one object is string. Exception is PoqFilterCategory
/// Since we want unification - we need protocol
public protocol FilterTypeValue {
    
    /// Presentation for end user
    var textRepresentation: String { get }
}

public protocol FilterViewControllerDelegate {
    func filtersModalDidDismiss( filters: PoqFilter )
}

public enum FilterType: String {
    
    // TODO need to update to lowercase.
    // Do not update if swiftlint ask for, can break clients.
    // The change is a refactor and needs to be scheduled.
    case Brand = "brand"
    case Category = "category"
    case Color = "color"
    case Size = "size"
    case Style = "style"
    
    var title: String {
        let appLocalization = AppLocalization.sharedInstance
        var res: String = ""
        switch self {
        case .Brand:
            res = appLocalization.filterTypeBrandTitle
        case .Category:
            res = appLocalization.filterTypeCategoryTitle
        case .Color:
            res = appLocalization.filterTypeColourTitle
        case .Size:
            res = appLocalization.filterTypeSizeTitle
        case .Style:
            res = appLocalization.filterTypeStyleTitle
        }
        
        return res
    }
}

// TODO: We have a big work here of preparing data for work with app. Looks like we can separate it into view model
open class ProductListFiltersController: PoqBaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    override open var screenName: String {
        return "Filter Screen"
    }
    
    // MARK: - Attributes
    var cellIdentifier = "filterCell"
    
    /// We will keep some data separatly from filters object
    /// We do it for more comfortable usage, since there is no data model
    public var filterTypes = [FilterType]()
    public var selectedCellsPerFilterMap = [FilterType: [Int]]()
    fileprivate var sources = [FilterType: [FilterTypeValue]]()
    
    public var currentFilter: FilterType? {
        guard let filterTypesSegmentedControlUnwrapped = filterTypesSegmentedControl, filterTypes.count > filterTypesSegmentedControlUnwrapped.selectedIndex else {
            return nil
        }
        let filterType: FilterType = filterTypes[filterTypesSegmentedControlUnwrapped.selectedIndex]
        return filterType
    }
    
    public var currentSource: [FilterTypeValue] {
        guard let filter: FilterType = currentFilter, sources.count > 0 else {
            return []
        }
        
        guard let currentSource: [FilterTypeValue] = sources[filter] else {
            return []
        }
        return currentSource
    }
    
    open var filters: PoqFilter? {
        didSet {
            createFilterTypes(filters)
        }
    }
    
    open var delegate: FilterViewControllerDelegate?
    
    // MARK: - UI Outlets
    
    @IBOutlet weak var filterTypesSegmentedControl: ADVSegmentedControl?
    @IBOutlet weak open var filterTypesTableView: UITableView? {
        didSet {
            filterTypesTableView?.backgroundColor = AppTheme.sharedInstance.filterTypesTableCellBackgroundColor
            filterTypesTableView?.backgroundView = nil
            filterTypesTableView?.tableFooterView = UIView(frame: CGRect.zero)
        }
    }
    @IBOutlet open weak var rangeSliderView: UIView?
    @IBOutlet open weak var rangeSlider: RangeSlider?
    @IBOutlet open weak var rangeSliderHeightConstraint: NSLayoutConstraint?
    @IBOutlet var rangeViewTopConstraintToSafeArea: NSLayoutConstraint?
    @IBOutlet var rangeViewTopConstraint: NSLayoutConstraint?
    
    @IBOutlet open weak var clearButtonToolbar: UIToolbar?
    @IBOutlet open weak var clearButton: UIBarButtonItem?
    @IBOutlet open weak var doneButton: UIBarButtonItem?
    
    @IBOutlet open weak var upperValueLabel: UILabel?
    @IBOutlet open weak var lowerValueLabel: UILabel?
    
    private var previousMin: Double?
    private var previousMax: Double?
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        configureViews()
        
        extendedLayoutIncludesOpaqueBars = false
        
        navigationController?.navigationBar.isTranslucent = false
    }
    
    func configureViews() {
        
        setupClearButton()
        setupNavigationButtons()
        setupNavigationTitle()
        setupSegmentedControl()
        setupPriceSlider()
    }
    
    open func setupPriceSlider() {
        
        if let filterPrices = filters?.prices,
            !filterPrices.isEmpty,
            AppSettings.sharedInstance.shouldShowFilterPriceSlider == true {

            // Add range slider
            rangeSlider?.trackHighlightTintColor = AppTheme.sharedInstance.trackHighlightTintColor
            rangeSlider?.trackTintColor = AppTheme.sharedInstance.trackTintColor
            rangeSlider?.thumbTintColor = AppTheme.sharedInstance.thumbTintColor
            
            upperValueLabel?.font = AppTheme.sharedInstance.filterPriceFont
            lowerValueLabel?.font = AppTheme.sharedInstance.filterPriceFont
            
            upperValueLabel?.isAccessibilityElement = true
            upperValueLabel?.accessibilityLabel = AccessibilityLabels.maxValue
            lowerValueLabel?.isAccessibilityElement = true
            lowerValueLabel?.accessibilityLabel = AccessibilityLabels.minValue
            
            let height: CGFloat = AppSettings.sharedInstance.customisedRangeSlider ? CGFloat(AppSettings.sharedInstance.rangeSliderCustomisedHeight) : 30.0
            rangeSlider?.sliderTrackHeight = AppSettings.sharedInstance.customisedRangeSlider ? CGFloat(AppSettings.sharedInstance.rangeSliderTrackCustomisedHeight) : height / 3
            rangeSliderHeightConstraint?.constant = height
            
            rangeViewTopConstraint?.isActive = false
            rangeViewTopConstraintToSafeArea?.isActive = true
            rangeViewTopConstraintToSafeArea?.priority = UILayoutPriority(rawValue: 999)
            
            updatePricesSlider()
        } else {
            
            rangeSliderView?.removeFromSuperview()
        }
    }
    
    func setupSegmentedControl() {
        
        let isSegmentedControlEnabled = filterTypes.count > 0
        
        if isSegmentedControlEnabled {
            
            filterTypesSegmentedControl?.items = filterTypes.map {
                $0.title
            }
            filterTypesSegmentedControl?.font = AppTheme.sharedInstance.filterTypeUnselectedFont
            filterTypesSegmentedControl?.selectedLabelFont = AppTheme.sharedInstance.filterTypeSelectedFont
            filterTypesSegmentedControl?.unselectedLabelColor = AppTheme.sharedInstance.filterTypeUnselectedLabelColor
            filterTypesSegmentedControl?.selectedLabelColor = AppTheme.sharedInstance.filterTypeSelectedLabelColor
            filterTypesSegmentedControl?.addTarget(self, action: #selector(ProductListFiltersController.segmentValueChanged(_:)), for: .valueChanged)
            filterTypesSegmentedControl?.selectedBackgroundColor = AppTheme.sharedInstance.filterTypeSelectedBackgroundColor
            filterTypesSegmentedControl?.unselectedBackgroundColor = AppTheme.sharedInstance.filterTypeDefaultBackgroundColor
            // Set first segment selected
    
            filterTypesSegmentedControl?.selectedIndex = 0
            
        } else {
            filterTypesSegmentedControl?.removeFromSuperview()
            filterTypesTableView?.removeFromSuperview()
        }
    }
    
    open func setupNavigationTitle() {
        
        let titleLabel: UILabel = NavigationBarHelper.setupTitleView(AppLocalization.sharedInstance.filtersNavigationTitle,
                                                                     titleFont: AppTheme.sharedInstance.filterTypeTitleFont)
        navigationItem.titleView = titleLabel
    }
    
    open func setupClearButton() {
        
        clearButton?.setTitleTextAttributes([NSAttributedStringKey.font: AppTheme.sharedInstance.filterClearAllTypeNaviBtnFont], for: UIControlState())
        clearButton?.setTitleTextAttributes([NSAttributedStringKey.font: AppTheme.sharedInstance.filterClearAllTypeNaviBtnFont], for: UIControlState.selected)
        clearButton?.tintColor = AppTheme.sharedInstance.filterClearAllColor
        clearButton?.title = AppLocalization.sharedInstance.filterClearAllTitle
        clearButtonToolbar?.barTintColor = AppTheme.sharedInstance.filterClearAllBackgroundColor
    }
    
    open func setupNavigationButtons() {
        
        let rightButtonTitle = AppLocalization.sharedInstance.filterViewDoneButtonText
      
        let doneButton = NavigationBarHelper.createButtonItem(withTitle: rightButtonTitle, target: self, action: #selector(doneButtonClick(_:)), position: .right)
        doneButton.accessibilityIdentifier = AccessibilityLabels.noFilters
        navigationItem.rightBarButtonItem = doneButton
        self.doneButton = doneButton
        
        if AppSettings.sharedInstance.filterPageShowCloseButton {
            navigationItem.leftBarButtonItem = NavigationBarHelper.setupCloseButton(self)
        } else {
            let cancelTitle = AppLocalization.sharedInstance.filterViewCancelButtonText
            navigationItem.leftBarButtonItem = NavigationBarHelper.createButtonItem(withTitle: cancelTitle, target: self, action: #selector(cancelButtonClick(_:)), position: .left)
        }
    }
    
    open func updatePricesSlider() {
        
        // Make sure we has prices and slider presented
        guard let existedRangeSliderView: UIView = rangeSliderView, let existedPrices: [Double] = self.filters?.prices, existedPrices.count >= 2 && existedRangeSliderView.superview != nil else {
            return
        }
        let minimumValue = floor(Double(existedPrices[0]))
        var maximumValue = ceil(Double(existedPrices[1]))
        
        maximumValue = maximumValue == minimumValue ? maximumValue + 1 : maximumValue
        
        // Add range slider
        rangeSlider?.maximumValue = maximumValue
        rangeSlider?.minimumValue = minimumValue
        rangeSlider?.lowerValue = minimumValue
        rangeSlider?.upperValue = maximumValue
        
        if let selectedmaxPrice = filters?.selectedMaxPrice {
            
            let finalMax = maximumValue > Double(selectedmaxPrice) && selectedmaxPrice != 0 ? Double(selectedmaxPrice) : Double(maximumValue)
            // MaximumValue:980, selectedmaxPrice=116
            // Then select 116
            
            rangeSlider?.upperValue = Double(finalMax)
        }
        
        if let selectedminPrice = filters?.selectedMinPrice {
            
            var finalMin = minimumValue > Double(selectedminPrice) ? Double(minimumValue) : Double(selectedminPrice)
            // MinimumValue =10, selectedMinPrice= 845 , maximumValue = 345
            // Take the 10 as final minimum value if the max < selectedMinPrice
            finalMin = finalMin > maximumValue ? minimumValue : finalMin
            rangeSlider?.lowerValue = Double(finalMin)
        }
        
        updateRangeLabelsTexts()
    }
    
    // Fill in selected values coming from filter object
    func fillInSelectedValues(_ filledInArray:inout [Int], selectedFilters: [String], filters: [String]) {
        
        // Fill in selected brands
        for selectedFilter in selectedFilters {
            
            if let index = filters.index(of: selectedFilter) {
                
                filledInArray.append(index)
            }
        }
    }
    
    @IBAction func rangeSliderValueChanged(_ rangeSlider: RangeSlider) {
        
        updateRangeLabelsTexts()
    }
    
    // MARK: - UI Outlet Actions
    
    @objc open func cancelButtonClick(_ sender: AnyObject) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc open func doneButtonClick(_ sender: AnyObject) {
        
        applyFilters()
    }
    
    override open func closeButtonClicked() {
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc open func applyFilters() {
        
        guard let exitedFilters: PoqFilter = filters else {
            return
        }
        
        exitedFilters.selectedBrands = filterArray(selectedCellsPerFilterMap[.Brand], target: exitedFilters.brands)
        
        let selectedCategories: [PoqFilterCategory] = filterArray(selectedCellsPerFilterMap[.Category], target: exitedFilters.categories)
        exitedFilters.selectedCategories = selectedCategories.map {
            $0.id ?? ""
        }
        
        let colorsSelection: [Int]? = selectedCellsPerFilterMap[.Color]
        exitedFilters.selectedColors = filterArray(colorsSelection, target: exitedFilters.colours)
        filters?.selectedColorValues = filterArray(colorsSelection, target: exitedFilters.colourValues)
        
        let sizesSelection: [Int]? = selectedCellsPerFilterMap[.Size]
        exitedFilters.selectedSizes = filterArray(sizesSelection, target: exitedFilters.sizes)
        exitedFilters.selectedSizeValues = filterArray(sizesSelection, target: exitedFilters.sizeValues)
        
        exitedFilters.selectedStyles = filterArray( selectedCellsPerFilterMap[.Style], target: exitedFilters.styles)
        
        // Handling nil prices filters from DW
        if filters?.prices?.count != 0, let lowerValue = rangeSlider?.lowerValue, let upperValue = rangeSlider?.upperValue {
            
            // We on't set nil to prices, because we need left prices
            // Not reset if we already has min/max values from prev filtering
            if let oldLowerValue = filters?.prices?[0], Double(lowerValue) >= oldLowerValue.rounded(.down) {
                filters?.selectedMinPrice = Int(lowerValue)
            }
            
            // We have special case: self.filters?.prices?[0] == self.filters?.prices?[1]
            // In that we can't check on !=, since we specially increased top value
            if let oldUpperValue = filters?.prices?[1], Double(upperValue) <= oldUpperValue.rounded(.up) {
                filters?.selectedMaxPrice = Int(upperValue)
            }
        }
        
        dismiss(animated: true, completion: modalDidDismiss)
        
        // Log applied filters
        logAppliedFilters()
    }
    
    public func logAppliedFilters() {
        
        var brands = ""
        var colors = ""
        var categories = ""
        var sizes = ""
        var styles = ""
        
        var extraParams = [String: String]()
        
        if let selectedColors = self.filters?.selectedColors, selectedColors.count > 0 {
            
            // Example: Black;White;Red
            colors = selectedColors.joined(separator: ";")
            PoqTrackerHelper.trackApplyFilters(action: PoqTrackerActionType.Colours, colors, extraParams: extraParams)
        }
        
        if let selectedBrands = filters?.selectedBrands, selectedBrands.count > 0 {
            
            brands = selectedBrands.joined(separator: ";")
            extraParams["Brands"] = brands
            
            PoqTrackerHelper.trackApplyFilters(action: PoqTrackerActionType.Brands, brands, extraParams: extraParams)
        }
        
        if let selectedCategories = filters?.selectedCategories, selectedCategories.count > 0 {
            
            categories = selectedCategories.joined(separator: ";")
            extraParams["Categories"] = categories
            PoqTrackerHelper.trackApplyFilters(action: PoqTrackerActionType.Categories, categories, extraParams: extraParams)
        }
        
        if let selectedSizes = filters?.selectedSizes, selectedSizes.count > 0 {
            
            sizes = selectedSizes.joined(separator: ";")
            extraParams["Sizes"] = sizes
            PoqTrackerHelper.trackApplyFilters(action: PoqTrackerActionType.Sizes, sizes, extraParams: extraParams)
        }
        
        if let selectedStyles = filters?.selectedStyles, selectedStyles.count > 0 {
            
            styles = selectedStyles.joined(separator: ";")
            extraParams["Styles"] = styles
            PoqTrackerHelper.trackApplyFilters(action: PoqTrackerActionType.Styles, styles, extraParams: extraParams)
        }
        
        if let minPrice = filters?.selectedMinPrice {
            
            extraParams["MinPrice"] = String(minPrice)
            if let lowerValue = rangeSlider?.lowerValue, previousMin != lowerValue {
                PoqTrackerHelper.trackApplyFilters(action: PoqTrackerActionType.MinPrice, colors, extraParams: extraParams)
            }
        }
        
        if let maxPrice = filters?.selectedMaxPrice {
            
            extraParams["MaxPrice"] = String(maxPrice)
            if let upperValue = rangeSlider?.upperValue, previousMax != upperValue {
                PoqTrackerHelper.trackApplyFilters(action: PoqTrackerActionType.MaxPrice, colors, extraParams: extraParams)
            }
        }
        
        let filterType = NetworkSettings.shared.productListFilterType == ProductListFiltersType.dynamic.rawValue ? "dynamic" : "static"
        PoqTrackerV2.shared.filterProducts(type: filterType, colors: colors, categories: categories, sizes: sizes, brands: brands, styles: styles, minPrice: filters?.selectedMinPrice ?? 0, maxPrice: filters?.selectedMaxPrice ?? 0)
    }
    
    public func modalDidDismiss() {
        guard let validFilters = self.filters else {
            return
        }
        delegate?.filtersModalDidDismiss( filters: validFilters )
    }
    
    @IBAction public func clearButtonClick(_ sender: AnyObject) {
        
        resetFilters()
    }
    
    @objc public func resetFilters() {
        
        // CLEAR_SELECTED_FILTERS
        let resetDialogTitle = AppLocalization.sharedInstance.filterResetDialogTitle
        let resetCurrentTitle = AppLocalization.sharedInstance.filterResetCurrentSelectionTitle
        let resetAllTitle = AppLocalization.sharedInstance.filterResetAllSelectionTitle
        
        let validAlertController = UIAlertController.init(title: resetDialogTitle, message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        self.alertController = validAlertController
        
        validAlertController.addAction(UIAlertAction.init(title: resetCurrentTitle, style: UIAlertActionStyle.default, handler: { [weak self] (_: UIAlertAction) in
            
            guard let filterTypes: [FilterType] = self?.filterTypes,
                let segmentedControl: ADVSegmentedControl = self?.filterTypesSegmentedControl, filterTypes.count > 0 else {
                    return
            }
            
            let filterType: FilterType = filterTypes[segmentedControl.selectedIndex]
            
            self?.selectedCellsPerFilterMap[filterType] = []
            
            switch filterType {
                
            case .Brand:
                self?.filters?.selectedBrands = []
                
            case .Category:
                self?.filters?.selectedCategories = []
                
            case .Color:
                self?.filters?.selectedColors = []
                self?.filters?.selectedColorValues = []
                
            case .Size:
                self?.filters?.selectedSizes = []
                self?.filters?.selectedSizeValues = []
                
            case .Style:
                self?.filters?.selectedStyles = []
            }
            
            self?.filterTypesTableView?.reloadData()
            
            // Reset prices
            self?.filters?.selectedMinPrice = nil
            self?.filters?.selectedMaxPrice = nil
            self?.updatePricesSlider()
        }))
        
        validAlertController.addAction( UIAlertAction.init(title: resetAllTitle, style: UIAlertActionStyle.destructive, handler: { [weak self] (_: UIAlertAction) in
            
            guard let filterTypes: [FilterType] = self?.filterTypes else {
                return
            }
            
            for filterType in filterTypes {
                self?.selectedCellsPerFilterMap[filterType] = []
            }
            
            self?.filters?.selectedBrands = []
            self?.filters?.selectedCategories = []
            self?.filters?.selectedColors = []
            self?.filters?.selectedColorValues = []
            self?.filters?.selectedSizes = []
            self?.filters?.selectedSizeValues = []
            self?.filters?.selectedStyles = []
            self?.filterTypesTableView?.reloadData()
            
            // Reset prices
            self?.filters?.selectedMinPrice = nil
            self?.filters?.selectedMaxPrice = nil
            
            self?.updatePricesSlider()
            
        }))
        
        validAlertController.addAction(UIAlertAction.init(title: AppLocalization.sharedInstance.filterViewCancelButtonText, style: UIAlertActionStyle.cancel, handler: { (_: UIAlertAction) in
        }))
        
        self.present(validAlertController, animated: true) {
            // Completion handler once everything is dismissed
        }
    }
    
    @objc func segmentValueChanged(_ sender: AnyObject?) {
        
        // Clear table
        self.filterTypesTableView?.reloadData()
    }
    
    @IBAction func filterTypesSegmentChanged(_ sender: AnyObject) {
        
        // Clear table
        filterTypesTableView?.reloadData()
    }
    
    // MARK: - TableView Delegations
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentSource.count
    }
    
    /* Table row rendering */
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var tableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if tableViewCell == nil {
            
            tableViewCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: cellIdentifier)
        }

        guard let cell = tableViewCell else {
            return UITableViewCell()
        }
        
        // Find current index in releated cell list and mark/unmark the cell
        cell.textLabel?.textColor = AppTheme.sharedInstance.filterCellTextColor
        cell.textLabel?.font = AppTheme.sharedInstance.filterCellTextFont
        cell.tintColor = AppTheme.sharedInstance.filterCellTintColor
        
        let cellText = LabelStyleHelper.checkCases(currentSource[indexPath.row].textRepresentation)
        
        cell.textLabel?.text = cellText
        cell.backgroundView = nil
        cell.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = UIColor.clear
        
        if let filterType = currentFilter, let indexesArray: [Int]  = selectedCellsPerFilterMap[filterType] {
            let isMarked: Bool = indexesArray.contains(indexPath.row)
            cell.accessoryType = isMarked ? .checkmark : .none
        } else {
            cell.accessoryType = .none
        }
        
        cell.accessoryView?.backgroundColor = UIColor.clear
        
        return cell
    }
    
    /* Table row selection */
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedIndex = indexPath.row
        
        // Get selected cell and call deselect to give instant UI feedback
        // Otherwise, user needs to tap double time to unselect/select
        let selectedCell = tableView.cellForRow(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: false)
        
        guard let selectedFilterType = currentFilter else {
            Log.error("filterTypesSegmentedControl = = nil")
            return
        }
        
        // Identify selected segment
        var selectedIndexes: [Int]? = selectedCellsPerFilterMap[selectedFilterType]
        
        if let index: Int = selectedIndexes?.index(of: selectedIndex) {
            selectedCell?.accessoryType = UITableViewCellAccessoryType.none
            selectedIndexes?.remove(at: index)
        } else {
            selectedCell?.accessoryType = UITableViewCellAccessoryType.checkmark
            selectedIndexes?.append(selectedIndex)
        }
        
        selectedCellsPerFilterMap[selectedFilterType] = selectedIndexes
    }
    
    // MARK: - Private
    
    /**
     Recreate filterTypes array, updates all pre-selections, create sources
     IN general prepare all internal ivars for comfortable life
     */
    fileprivate final func  createFilterTypes(_ filters: PoqFilter?) {
        
        filterTypes = []
        
        guard let existedFilters: PoqFilter = filters else {
            return
        }
        
        sources[.Brand] = existedFilters.brands?.map { $0 as FilterTypeValue } ?? []
        sources[.Category] = existedFilters.categories?.map { $0 as FilterTypeValue } ?? []
        sources[.Color] = existedFilters.colours?.map { $0 as FilterTypeValue } ?? []
        sources[.Size] = existedFilters.sizes?.map { $0 as FilterTypeValue } ?? []
        sources[.Style] = existedFilters.styles?.map { $0 as FilterTypeValue } ?? []
        
        let filterString: String = AppSettings.sharedInstance.desiredFiltersOrder
        // TODO: we really need here trim spaces to avoid stupid mistakes
        let filterTypeStrings: [String] = filterString.components(separatedBy: ",")
        
        for typeString: String in filterTypeStrings {
            guard let filterType = FilterType(rawValue: typeString) else {
                print("ERROR:  we can't create FilterType with string: \(typeString)")
                continue
            }
            
            guard let source = sources[filterType], source.count > 0 else {
                continue
            }
            
            filterTypes.append(filterType)
            
            // Lets select already existed (preselected ) filters in PoqFilter
            selectedCellsPerFilterMap[filterType] = filterType.preselectedCellIndexes(fromFilter: existedFilters)
        }
    }
    
    fileprivate final func updateRangeLabelsTexts() {
        
        if let upperValue = rangeSlider?.upperValue {
            upperValueLabel?.text = String(format: "\(CurrencyProvider.shared.currency.symbol)%d", Int(upperValue))
        }
        
        if let lowerValue = rangeSlider?.lowerValue {
            lowerValueLabel?.text = String(format: "\(CurrencyProvider.shared.currency.symbol)%d", Int(lowerValue))
        }
    }
}

// MARK: - Private

extension FilterType {
    
    fileprivate func preselectedCellIndexes(fromFilter filter: PoqFilter) -> [Int] {
        
        typealias FilterValues = (allValue: [String]?, selectedValues: [String]?)
        
        var filterValue: FilterValues
        switch self {
        case .Brand:
            filterValue = (allValue: filter.brands, selectedValues: filter.selectedBrands)
        case .Category:
            let categoryIds: [String] = ( filter.categories?.map { $0.id ?? "" }) ?? []
            filterValue = (allValue: categoryIds, selectedValues: filter.selectedCategories)
        case .Color:
            filterValue = (allValue: filter.colours, selectedValues: filter.selectedColors)
        case .Size:
            filterValue = (allValue: filter.sizes, selectedValues: filter.selectedSizes)
        case .Style:
            filterValue = (allValue: filter.styles, selectedValues: filter.selectedStyles)
        }
        
        // Fill in selected brands
        var res = [Int]()
        let allFilters: [String] = filterValue.allValue ?? []
        for selectedFilter in (filterValue.selectedValues ?? [] ) {
            
            if let index = allFilters.index(of: selectedFilter) {
                res.append(index)
            }
        }
        
        return res
    }
}

public func filterArray<T>(_ indexes: [Int]?, target: [T]?) -> [T] {
    guard let existedTarget: [T] = target, let existedIndexes: [Int] = indexes else {
        return []
    }
    var result = [T]()
    for index: Int in existedIndexes {
        guard existedTarget.count > index else {
            print("ERROR: while filtering array - target has not enough values for indexes, index: \(index)")
            continue
        }
        result.append(existedTarget[index])
    }
    
    return result
}

extension String: FilterTypeValue {

    public var textRepresentation: String {
        return self
    }
}

extension PoqFilterCategory: FilterTypeValue {

    public var textRepresentation: String {
        return title ?? ""
    }
}
