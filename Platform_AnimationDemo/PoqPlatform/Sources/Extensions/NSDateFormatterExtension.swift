//
//  NSDateFormatterExtension.swift
//  Poq.iOS.Belk
//
//  Created by Balaji Reddy on 04/01/2017.
//
//

import Foundation

extension DateFormatter {
    
   @nonobjc
   open func formatFromUTCToLocal(_ dateString: String, fromFormat: String, toFormat: String) -> String? {
        dateFormat = fromFormat
        timeZone = TimeZone(identifier: "UTC")
        if let date = date(from: dateString) {
            timeZone = TimeZone.autoupdatingCurrent
            dateFormat = toFormat
            return string(from: date)
        }
        return nil
    }
    
    @nonobjc
    static let iso8601DateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        return formatter
    }()
    
}
