//
//  UIColorExtension.swift
//  Poq.iOS.Platform
//
//  Created by Nikolay Dzhulay on 9/1/17.
//
//

import Foundation
import PoqUtilities
import UIKit

extension UIColor {
    
    // MARK: Public Extension Implementation methods
    
    /**
     Creates `UIColor` object based on given hexadecimal color value
     
     - Parameter hex: String with the hex information. With or without hash symbol.
     - returns: A UIColor from the given String or gray UIColor if the String does not match the requirements.
     - Throws: `MyError.InvalidWhatever` We will provide this if the function throws
     
     ## Usage Example: ##
     ````
     let redHexColor = UIColor.hexColor("#ff0000")
     ````
     **Note:** You can make notes here aboit whatever you want. For example, I would like to refactor this function since it can be shorter and it uses blah blah
     */
    @nonobjc
    public class func hexColor(_ hex: String) -> UIColor {
        
        var color = UIColor.gray
        
        // Trimming String in case we have some white space
        let trimmedColor = hex.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).uppercased()
        
        // Return UIColor.gray if no initial hash
        guard trimmedColor.hasPrefix("#") == true else {
            
            Log.error("Hex Color String do not have initial hash: \(trimmedColor)")
            return color
        }
        
        // Remove hash
        let noHashColor = trimmedColor.replacingOccurrences(of: "#", with: "")
        
        if (noHashColor.count == 8) {
            
            color = colorWithHexAlpha(noHashColor)
        } else if (noHashColor.count == 6) {
            
            color = colorWithHexNoAlpha(noHashColor)
        } else if (noHashColor.count == 3) {
            
            color = colorWithShorthandHex(noHashColor)
        }
        
        return color
    }
    
    // MARK: - Private Extension Implementation methods
    
    /**
     Creates UIColor object based on given hexadecimal color value with alpha (aarrggbb).
     
     - Parameter hexColor: String with the hex information.
     - returns: A UIColor from the given String or gray UIColor if can not be formated.
     
     ## Usage Example: ##
     ````
     let redHexColor = UIColor.colorWithHexAlpha("#ff0000")
     ````
     **Note:** This func is private
     */
    @nonobjc
    fileprivate class func colorWithHexAlpha(_ hex: String) -> UIColor {
        
        var color = UIColor.gray
        
        let red: CGFloat
        let green: CGFloat
        let blue: CGFloat
        let alpha: CGFloat
        
        if hex.count == 8 {
            
            let scanner = Scanner(string: hex)
            var hexNumber: UInt64 = 0
            
            if scanner.scanHexInt64(&hexNumber) {
                
                alpha = CGFloat((hexNumber & 0xff000000) >> 24) / 255.0
                red = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255.0
                green = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255.0
                blue = CGFloat(hexNumber & 0x000000ff) / 255.0
                
                color = UIColor(red: red,
                                green: green,
                                blue: blue,
                                alpha: alpha)
            }
        }
        
        return color
    }
    
    /**
     Creates UIColor object based on given hexadecimal color value without alpha (rrggbb) by adding alpha 1.0 to the given hex color.
     
     - Parameter hexColor: String with the hex information.
     - returns: A UIColor from the given String.
     
     ## Usage Example: ##
     ````
     let redHexColor = UIColor.colorWithHexNoAlpha("#ff0000")
     ````
     **Note:** This func is private
     */
    @nonobjc
    fileprivate class func colorWithHexNoAlpha(_ hexColor: String) -> UIColor {
        
        return colorWithHexAlpha(String(format: "FF%@", hexColor))
    }
    
    /**
     Creates UIColor object based on given short hexadecimal color value without alpha (rgb). Alpha will be 1.0.
     
     - Parameter hexColor: String with the hex information.
     - returns: A UIColor from the given String.
     
     ## Usage Example: ##
     ````
     let redHexColor = UIColor.colorWithShorthandHex("#ff0000")
     ````
     **Note:** This func is private
     */
    @nonobjc
    fileprivate class func colorWithShorthandHex(_ hexColor: String) -> UIColor {
        
        let red = String(hexColor[0] as Character)
        let green = String(hexColor[1] as Character)
        let blue = String(hexColor[2] as Character)
        
        let hex = String(format: "%@%@%@%@%@%@", red, red, green, green, blue, blue)
        
        return colorWithHexNoAlpha(hex)
    }

}
