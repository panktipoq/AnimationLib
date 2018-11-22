//
//  DateHelper.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 18/08/2015.
//  Copyright (c) 2015 Poq. All rights reserved.
//

import Foundation

public enum DayOfWeek:Int {
    
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
}

public class DateHelper {
    
    public final var calendar:Calendar
    public final var dateComponents:DateComponents
    public final var dayOfWeek:Int
    public let dateFormatter = DateFormatter()
    public let birthdayFormat = "dd/MM/yyyy"
    public let apiBirthdaFormat = "yyyy-MM-dd"

    public init() {
        
        calendar = Calendar.current
        dateComponents = (calendar as NSCalendar).components(NSCalendar.Unit.weekday , from: Date())
        dayOfWeek = dateComponents.weekday!
    }
    
    public func isToday(_ dayOfWeek:DayOfWeek) -> Bool {
        
        return self.dayOfWeek == dayOfWeek.rawValue
    }
    
    public func birthdayDateFormat(_ date: Date) -> String {
        dateFormatter.dateFormat = birthdayFormat
        return dateFormatter.string(from: date)

    }
    
    /// Convert user friendly date format to api format 
    public func apiSaveDateFormat(_ date: String) -> String? {
        dateFormatter.dateFormat = birthdayFormat
        let newDate = dateFormatter.date(from: date)
        dateFormatter.dateFormat = apiBirthdaFormat
        dateFormatter.locale = Locale(identifier: AppSettings.sharedInstance.dateLocale)
        guard let date = newDate else {
            return nil
        }
        return dateFormatter.string(from: date)
    }
    
    /// Convert api format to user friendly date format 
    public func birthdayDateFormat(fromApiDate dateOrNil: String?) -> String? {
        guard let dateString = dateOrNil else {
            return nil
        }

        dateFormatter.dateFormat = apiBirthdaFormat
        dateFormatter.locale = Locale(identifier: AppSettings.sharedInstance.dateLocale)
        
        // API return other fromat from expected, so lets try parse other format
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "dd-MM-yyyy"
        dateFormatter2.locale = Locale(identifier: AppSettings.sharedInstance.dateLocale)
        
        let dateOrNil = dateFormatter.date(from: dateString) ?? dateFormatter2.date(from: dateString) 
        guard let date = dateOrNil else {
            return nil
        }
        
        dateFormatter.dateFormat = birthdayFormat
        dateFormatter.locale = Locale.current
        return dateFormatter.string(from: date)
    }
    
    public func getBirthdayDate(_ date: String?) -> Date? {
        dateFormatter.dateFormat = birthdayFormat
        if let birthDate = date{
            return dateFormatter.date(from: birthDate)
        }
        return nil
    }
    
    public func getDefaultDate() -> Date? {
        dateFormatter.dateFormat = birthdayFormat
        return dateFormatter.date(from: AppSettings.sharedInstance.editMyProfileDefaultDateChoose)
    }
    
    public func getMinimumDate() -> Date? {
        dateFormatter.dateFormat = birthdayFormat
        return dateFormatter.date(from: AppSettings.sharedInstance.editMyProfilePastDateIntervalStart)
    }

}
