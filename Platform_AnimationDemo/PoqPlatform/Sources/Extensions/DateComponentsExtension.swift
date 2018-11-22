//
//  DateComponentsExtension.swift
//  Poq.iOS.Belk
//
//  Created by Manuel Marcos Regalado on 04/03/2017.
//
//

import Foundation

/*
 This extension will convert the Int type that we get from `self.month`to
 a full String name of the corresponding month.
 */

public extension DateComponents {
    @nonobjc
    var monthString: String {
        let dateFormatter = DateFormatter()
        guard let monthInt = self.month else {
            return ""
        }
        return dateFormatter.monthSymbols[monthInt - 1]
    }
}
