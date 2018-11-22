//
//  StoreDetailTableViewHoursCell.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 18/08/2015.
//  Copyright (c) 2015 Poq. All rights reserved.
//

import Foundation
import PoqNetworking

open class StoreDetailTableViewHoursCell: UITableViewCell {
    
    // MARK: - Class attributes
    // _____________________________
    
    // Custom view XIB, Identifier and custom Height

    public static let CellXib:String = "StoreDetailTableViewHoursCellView"
    public static let CellHeight:CGFloat = CGFloat(AppSettings.sharedInstance.storeDetailHoursCellHeight)
    
    
    // MARK: - IBOutlets
    // _____________________________
    
    @IBOutlet open weak var openingHoursTitleLabel: UILabel!{
        didSet{
            openingHoursTitleLabel.font = AppTheme.sharedInstance.storeDetailOpeningHoursTitleFont
            openingHoursTitleLabel.text = AppLocalization.sharedInstance.storeOpeningHoursText
        }
    }
    @IBOutlet weak var openingHoursTitleRulerView: UIView!
    
    @IBOutlet open weak var mondayLabel: UILabel! {
        
        didSet {
            
            setColorAndFontByCheckingDayOfWeek(DayOfWeek.monday, label: mondayLabel)
        }
    }
    
    @IBOutlet open weak var tuesdayLabel: UILabel! {
        
        didSet {
            
            setColorAndFontByCheckingDayOfWeek(DayOfWeek.tuesday, label: tuesdayLabel)
        }
    }

    @IBOutlet open weak var wednesdayLabel: UILabel! {
        
        didSet {
            
            setColorAndFontByCheckingDayOfWeek(DayOfWeek.wednesday, label: wednesdayLabel)
        }
    }

    @IBOutlet open weak var thursdayLabel: UILabel! {
        
        didSet {
            
            setColorAndFontByCheckingDayOfWeek(DayOfWeek.thursday, label: thursdayLabel)
        }
    }

    @IBOutlet open weak var fridayLabel: UILabel! {
        
        didSet {
            
            setColorAndFontByCheckingDayOfWeek(DayOfWeek.friday, label: fridayLabel)
        }
    }

    @IBOutlet open weak var saturdayLabel: UILabel! {
        
        didSet {
            
            setColorAndFontByCheckingDayOfWeek(DayOfWeek.saturday, label: saturdayLabel)
        }
    }

    @IBOutlet open weak var sundayLabel: UILabel! {
        
        didSet {
            
            setColorAndFontByCheckingDayOfWeek(DayOfWeek.sunday, label: sundayLabel)
        }
    }

    @IBOutlet open weak var mondayHoursLabel: UILabel! {
        
        didSet {
            
            setColorAndFontByCheckingDayOfWeek(DayOfWeek.monday, label: mondayHoursLabel)
        }
    }

    @IBOutlet open weak var tuesdayHoursLabel: UILabel! {
        
        didSet {
            
            setColorAndFontByCheckingDayOfWeek(DayOfWeek.tuesday, label: tuesdayHoursLabel)
        }
    }

    @IBOutlet open  weak var wednesdayHoursLabel: UILabel! {
        
        didSet {
            
            setColorAndFontByCheckingDayOfWeek(DayOfWeek.wednesday, label: wednesdayHoursLabel)
        }
    }

    @IBOutlet open  weak var thursdayHoursLabel: UILabel! {
        
        didSet {
            
            setColorAndFontByCheckingDayOfWeek(DayOfWeek.thursday, label: thursdayHoursLabel)
        }
    }

    @IBOutlet open  weak var fridayHoursLabel: UILabel! {
        
        didSet {
            
            setColorAndFontByCheckingDayOfWeek(DayOfWeek.friday, label: fridayHoursLabel)
        }
    }

    @IBOutlet open  weak var saturdayHoursLabel: UILabel! {
        
        didSet {
            
            setColorAndFontByCheckingDayOfWeek(DayOfWeek.saturday, label: saturdayHoursLabel)
        }
    }

    @IBOutlet open  weak var sundayHoursLabel: UILabel! {
        
        didSet {
            
            setColorAndFontByCheckingDayOfWeek(DayOfWeek.sunday, label: sundayHoursLabel)
        }
    }

    
    
    
    // MARK: - UI Business Logic
    // _____________________________
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setDayOfWeekNames()
    }
    
    open func setDayOfWeekNames() {
        
        mondayLabel.text = AppLocalization.sharedInstance.mondayText
        tuesdayLabel.text = AppLocalization.sharedInstance.tuesdayText
        wednesdayLabel.text = AppLocalization.sharedInstance.wednesdayText
        thursdayLabel.text = AppLocalization.sharedInstance.thursdayText
        fridayLabel.text = AppLocalization.sharedInstance.fridayText
        saturdayLabel.text = AppLocalization.sharedInstance.saturdayText
        sundayLabel.text = AppLocalization.sharedInstance.sundayText
    }
    
    open func setOpeningHours(_ store:PoqStore) {
       mondayHoursLabel.text = getStoreOpeningTimesMonday(store, format: AppLocalization.sharedInstance.storeOpeningHoursFormat)
       tuesdayHoursLabel.text = getStoreOpeningTimesTuesday(store, format: AppLocalization.sharedInstance.storeOpeningHoursFormat)
       wednesdayHoursLabel.text = getStoreOpeningTimesWednesday(store, format: AppLocalization.sharedInstance.storeOpeningHoursFormat)
       thursdayHoursLabel.text = getStoreOpeningTimesThursday(store, format: AppLocalization.sharedInstance.storeOpeningHoursFormat)
       fridayHoursLabel.text = getStoreOpeningTimesFriday(store, format: AppLocalization.sharedInstance.storeOpeningHoursFormat)
       saturdayHoursLabel.text = getStoreOpeningTimesSaturday(store, format: AppLocalization.sharedInstance.storeOpeningHoursFormat)
       sundayHoursLabel.text = getStoreOpeningTimesSunday(store, format: AppLocalization.sharedInstance.storeOpeningHoursFormat)
    }
    
    open func setColorAndFontByCheckingDayOfWeek(_ dayOfWeek:DayOfWeek, label:UILabel) {
        
        if DateHelper().isToday(dayOfWeek) {
            
            label.font = AppTheme.sharedInstance.storeTodayFont
        }
        else {
            
            label.font = AppTheme.sharedInstance.storeOpeningHoursFont
        }
    }
    
    open func getStoreOpeningTime(_ format:String, openingTime:String?, closingTime:String?) -> String {
        
        if let opens = openingTime, let closes = closingTime {
            
            return String(format: format, arguments:[opens, closes])
        }
        else {
            
            return ""
        }
    }

    open func getStoreOpeningTimesMonday(_ store:PoqStore, format:String) -> String {
        
        return getStoreOpeningTime(format, openingTime: store.mondayOpenTime, closingTime: store.mondayCloseTime)
    }
    
    open func getStoreOpeningTimesTuesday(_ store:PoqStore, format:String) -> String {
        
        return getStoreOpeningTime(format, openingTime: store.tuesdayOpenTime, closingTime: store.tuesdayCloseTime)
    }
    
    open func getStoreOpeningTimesWednesday(_ store:PoqStore, format:String) -> String {
        
        return getStoreOpeningTime(format, openingTime: store.wednesdayOpenTime, closingTime: store.wednesdayCloseTime)
    }
    
    open func getStoreOpeningTimesThursday(_ store:PoqStore, format:String) -> String {
        
        return getStoreOpeningTime(format, openingTime: store.thursdayOpenTime, closingTime: store.thursdayCloseTime)
    }
    
    open func getStoreOpeningTimesFriday(_ store:PoqStore, format:String) -> String {
        
        return getStoreOpeningTime(format, openingTime: store.fridayOpenTime, closingTime: store.fridayCloseTime)
    }
    
    open func getStoreOpeningTimesSaturday(_ store:PoqStore, format:String) -> String {
        
        return getStoreOpeningTime(format, openingTime: store.saturdayOpenTime, closingTime: store.saturdayCloseTime)
    }
    
    open func getStoreOpeningTimesSunday(_ store:PoqStore, format:String) -> String {
        
        return getStoreOpeningTime(format, openingTime: store.sundayOpenTime, closingTime: store.sundayCloseTime)
    }
}
