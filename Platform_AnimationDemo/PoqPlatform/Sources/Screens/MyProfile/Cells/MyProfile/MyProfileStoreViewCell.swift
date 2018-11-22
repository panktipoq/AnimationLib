//
//  MyProfileStoreViewCell.swift
//  Poq.iOS.Belk
//
//  Created by Manuel Marcos Regalado on 08/12/2016.
//
//

import Foundation
import CoreLocation
import MapKit
import PoqNetworking

/// Protocol enforcing Favorite store block
public protocol FavouriteStoreBlockProtocol: AnyObject {
    func getStoreDetails() -> PoqStore?
    func isValidStore() -> Bool
}

/// Store cell's view model used to render a preview of the user's favorite cell
open class MyProfileStoreViewCell: FullWidthAutoresizedCollectionCell, MKMapViewDelegate, PoqMyProfileListReusableView {
    
    /// The presenter of the cell
    weak public var presenter: PoqMyProfileListPresenter?
    
    /// The view model behind the cell
    lazy var myProfileStoreCellViewModel: FavouriteStoreBlockProtocol = {
        let viewModel: MyProfileStoreCellViewModel = MyProfileStoreCellViewModel(myProfileStoreViewCellDelegate: self)
        return viewModel
    }()
    
    /// The title label left constraint
    @IBOutlet weak var titleLabelLeftConstraint: NSLayoutConstraint? {
        didSet {
            titleLabelLeftConstraint?.constant = AppSettings.sharedInstance.profileLinkCellLeftAlignment
        }
    }
    
    /// The mapview of the cell used to render a preview of the favorite store location
    @IBOutlet weak var mapView: MKMapView? {
        didSet {
            // Add accessibility for map
            mapView?.isAccessibilityElement = true
            mapView?.accessibilityLabel = AccessibilityLabels.storeMap
        }
    }
    
    /// The map pin representing the user's favorite store
    var dropPin: MKAnnotation?

    /// The title label of the cell used to render the store's name
    @IBOutlet weak var titleLabel: UILabel? {
        didSet {
            titleLabel?.font = AppTheme.sharedInstance.profileLinkFont
        }
    }
    
    /// The spinner view present when a data operation takes place
    @IBOutlet weak var spinnerView: PoqSpinner? {
        didSet {
            spinnerView?.tintColor = AppTheme.sharedInstance.mainColor
        }
    }
    
    /// The label showing the name
    @IBOutlet weak var nameLabel: UILabel? {
        didSet {
            nameLabel?.text = AppLocalization.sharedInstance.myProfileAddFavouriteStoreTitle
            nameLabel?.font = AppTheme.sharedInstance.storeNameFont
            nameLabel?.textColor = UIColor.black
            nameLabel?.textAlignment = NSTextAlignment.left
            let nameLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(MyProfileStoreViewCell.nameLabelTapped(_:)))
            nameLabel?.addGestureRecognizer(nameLabelTapGesture)
            nameLabel?.adjustsFontSizeToFitWidth = true
        }
    }
    
    /// The label showing the address
    @IBOutlet weak var addressLabel: UILabel? {
        didSet {
            addressLabel?.text = AppLocalization.sharedInstance.myProfileFavouriteStoreStockAvailabilityTitle
            addressLabel?.font = AppTheme.sharedInstance.favouriteStoreStockAvailabilityFont
            addressLabel?.textColor = UIColor.black
            addressLabel?.textAlignment = NSTextAlignment.left
            addressLabel?.adjustsFontSizeToFitWidth = true
        }
    }
    
    /// The label showing the store's opening hours
    @IBOutlet weak var openingHoursLabel: UILabel? {
        didSet {
            openingHoursLabel?.text = AppLocalization.sharedInstance.myProfileStoreOpeningHoursTitle
            openingHoursLabel?.font = AppTheme.sharedInstance.storeOpeningHoursFont
            openingHoursLabel?.textColor = AppTheme.sharedInstance.mainColor
            openingHoursLabel?.textAlignment = NSTextAlignment.left
            openingHoursLabel?.adjustsFontSizeToFitWidth = true
        }
    }

    /// The favorite store button
    @IBOutlet weak var favoriteButton: UIButton? {
        didSet {
            favoriteButton?.configurePoqButton(style: ResourceProvider.sharedInstance.clientStyle?.secondaryButtonStyle)
            setFavoriteButtonTitle()
        }
    }
    
    /// The call button
    @IBOutlet weak var callButton: CallButton?
    
    deinit {
        // Set to nil the map view delegate helps with memory management
        mapView?.delegate = nil
    }
    
    /// Called when the cell is being created from xib
    open override func awakeFromNib() {
        super.awakeFromNib()
        let heightConstraint = contentView.heightAnchor.constraint(equalToConstant: CGFloat(MyProfileSettings.myProfileMyStoreHeight))
        heightConstraint.priority = UILayoutPriority(rawValue: 999.0)
        heightConstraint.isActive = true
    }
    
    /// Updates the store details in the cell
    func showDetails() {
        
        toggleView(false)
        spinnerView?.stopAnimating()
        callButton?.isEnabled = true

        guard let store: PoqStore = myProfileStoreCellViewModel.getStoreDetails() else {
            return
        }
        
        nameLabel?.text = store.name
        addressLabel?.text = getStoreAddressText()
        openingHoursLabel?.text = getOpeningTimesText(store)
        drawStoreInMap(store)
        setFavoriteButtonTitle()
    }
    
    // MARK: - Helpers
    
    /// Sets the favorite button title
    func setFavoriteButtonTitle() {
        var favoriteButtonText = AppLocalization.sharedInstance.myProfileStoreChangeFavoriteText
        if !StoreHelper.hasFavoriteStore() {
            favoriteButtonText = AppLocalization.sharedInstance.myProfileStoreSetFavoriteText
        }
        favoriteButton?.setTitle(favoriteButtonText, for: UIControlState())
    }
    
    /// Draws the store's pin on the map
    ///
    /// - Parameter storeToDrawInMap: The store that needs to be drown on the map
    func drawStoreInMap(_ storeToDrawInMap: PoqStore?) {
        guard let store = storeToDrawInMap,
            let latitude = store.latitude,
            let longitude = store.longitude else {
            return
        }
        
        if let pinDropped = dropPin {
            
            mapView?.removeAnnotation(pinDropped)
        }
        
        let lat = (latitude as NSString).doubleValue
        let long = (longitude as NSString).doubleValue
        
        let location = CLLocationCoordinate2DMake(lat, long)
        let newPin = MKPointAnnotation()
        newPin.coordinate = location
        dropPin = newPin
        if let dropPinMap = dropPin {
            mapView?.addAnnotation(dropPinMap)
        }
        
        let selectedCoordinate: CLLocationCoordinate2D = location
        let longitudeDeltaDegrees: CLLocationDegrees = 0.03
        let latitudeDeltaDegrees: CLLocationDegrees = 0.03
        let userSpan = MKCoordinateSpanMake(latitudeDeltaDegrees, longitudeDeltaDegrees)
        let userRegion = MKCoordinateRegionMake(selectedCoordinate, userSpan)
        
        mapView?.setRegion(userRegion, animated: true)
    }
    
    /// Retursn the store address text
    ///
    /// - Returns: The store address
    func getStoreAddressText() -> String {
        var address = AppLocalization.sharedInstance.myProfileFavouriteStoreStockAvailabilityTitle
        
        if let store = myProfileStoreCellViewModel.getStoreDetails() {
            if let storeAddress = store.address {
                address = "\(storeAddress)"
            }
            if let storeAddress2 = store.address2 {
                address = "\(address), \(storeAddress2)"
            }
            if let city = store.city {
                address = "\(address), \(city)"
            }
        }
        return address
    }
    
    /// Returns the store opening times
    ///
    /// - Parameter store: The store object
    /// - Returns: The store opening times
    func getOpeningTimesText(_ store: PoqStore?) -> String {
        var openingTimes = ""

        guard let store = store else {
            return openingTimes
        }
        
        let calendar: Calendar = Calendar.current
        let dateComps: DateComponents = (calendar as NSCalendar).components(.weekday, from: Date())
        let dayOfWeek: Int = dateComps.weekday!
        let template = AppLocalization.sharedInstance.todaysOpeningHours
        let seperator = "-"
        let format = AppSettings.sharedInstance.myProfileFavoriteStoreOpeningTimesFormat
        
        if let openTime = store.sundayOpenTime, let closeTime = store.sundayCloseTime, dayOfWeek == 1 {
            
            openingTimes = template + String(format: format, arguments: [openTime, seperator, closeTime])
        } else if let openTime = store.mondayOpenTime, let closeTime = store.mondayCloseTime, dayOfWeek == 2 {
            
            openingTimes = template + String(format: format, arguments: [openTime, seperator, closeTime])
        } else if let openTime = store.tuesdayOpenTime, let closeTime = store.tuesdayCloseTime, dayOfWeek == 3 {
            
            openingTimes = template + String(format: format, arguments: [openTime, seperator, closeTime])
        } else if let openTime = store.wednesdayOpenTime, let closeTime = store.wednesdayCloseTime, dayOfWeek == 4 {
            
            openingTimes = template + String(format: format, arguments: [openTime, seperator, closeTime])
        } else if let openTime = store.thursdayOpenTime, let closeTime = store.thursdayCloseTime, dayOfWeek == 5 {
            
            openingTimes = template + String(format: format, arguments: [openTime, seperator, closeTime])
        } else if let openTime = store.fridayOpenTime, let closeTime = store.fridayCloseTime, dayOfWeek == 6 {
            
            openingTimes = template + String(format: format, arguments: [openTime, seperator, closeTime])
        } else if let openTime = store.saturdayOpenTime, let closeTime = store.saturdayCloseTime, dayOfWeek == 7 {
            
            openingTimes = template + String(format: format, arguments: [openTime, seperator, closeTime])
        }
        
        return openingTimes
    }
    
    /// Shows or hides the content of the store cell
    ///
    /// - Parameter visibility: Wether or not to show the contents of the cell
    func toggleView(_ visibility: Bool) {
        if !visibility {
            if let pinDropped = dropPin {
                mapView?.removeAnnotation(pinDropped)
            }
        }
        nameLabel?.isHidden = visibility
        favoriteButton?.isHidden = visibility
        callButton?.isHidden = visibility
        addressLabel?.isHidden = visibility
        openingHoursLabel?.isHidden = visibility
        callButton?.isEnabled = visibility
    }
    
    // MARK: - Actions
    
    /// Triggered when the name label has been tapped
    ///
    /// - Parameter gesture: The gesture that triggered the action
    @objc func nameLabelTapped(_ gesture: UIGestureRecognizer) {
        if let store = myProfileStoreCellViewModel.getStoreDetails(),
            let storeId = store.id,
            let storeTitle = store.name {
            NavigationHelper.sharedInstance.loadStoreDetail(storeId, storeTitle: storeTitle)
        }
    }
    
    /// Triggered when the favorite button is clicked
    ///
    /// - Parameter sender: The object that generated the action
    @IBAction func favoriteButtonClick(_ sender: AnyObject) {
        if let cellActionDelegate = presenter as? MyProfileViewCellActionDelegate {
            cellActionDelegate.triggerAction(MyProfileCellAction.selectStore)
            if let store = myProfileStoreCellViewModel.getStoreDetails(),
                let storeName = store.name {
                PoqTrackerHelper.trackAddStoreToFavorite(storeName)
            }
        }
    }
    
    /// Sets up the cell contents
    ///
    /// - Parameters:
    ///   - content: The cell content used to populate the store cell
    ///   - cellPresenter: The presenter that renders the cell
    public func setup(using content: PoqMyProfileListContentItem, cellPresenter: PoqMyProfileListPresenter) {
        
        guard let block = content.block else {
            return
        }
        
        titleLabel?.text = block.title
        presenter = cellPresenter
        showDetails()
    }
}

extension MyProfileStoreViewCell: CallButtonDelegate {
    
    /// Triggered when the call button has been clicked
    ///
    /// - Parameter sender: The object that generated the action
    @IBAction public func callButtonClicked(_ sender: Any?) {
        guard !DeviceType.IS_IPAD else {
            return
        }
        
        if let store = myProfileStoreCellViewModel.getStoreDetails() {
            if store.phone == nil {
                return
            }
            if let storePhone = store.phone {
                CallButtonHelper.launchPhoneCall(storePhone)
            }
        }
    }
}
