//
//  LabelStyleHelper
//  Poq.iOS
//
//  Created by Jun Seki on 13/02/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import UIKit

open class LabelStyleHelper {

    public static func initSignInTitlePlatformLabel() -> NSMutableAttributedString {

        let bigTitleFontDict = [NSAttributedStringKey.foregroundColor: AppTheme.sharedInstance.loginBigTitleLabelColor,
                                                     NSAttributedStringKey.font: AppTheme.sharedInstance.loginBigTitleLabelFont]
        let bigTitleAttrString = NSMutableAttributedString(string: AppLocalization.sharedInstance.signinTitle, attributes: bigTitleFontDict)

        return bigTitleAttrString
    }

    public static func initPriceLabel(_ price: Double?,
                                    specialPrice: Double?,
                                    isGroupedPLP: Bool = false,
                                    priceFormat: String = AppSettings.sharedInstance.priceFormat,
                                    singlePriceFont: UIFont = AppTheme.sharedInstance.singlePriceFont,
                                    priceFontStyle: UIFont = AppTheme.sharedInstance.priceFont,
                                    specialPriceFontStyle: UIFont = AppTheme.sharedInstance.specialPriceFont) -> NSMutableAttributedString {

        if let price = price, let specialPrice = specialPrice, specialPrice != price {

            // If there were 2 prices on the PLP, then the format will be Now £12.00 Was £40.00

            if !AppSettings.sharedInstance.strikethroughForNormalPrice {

                return createPriceAndSpecialPriceFontsWithoutStrikethrough(priceFontStyle, specialPriceFontStyle: specialPriceFontStyle, price: price, specialPrice: specialPrice, priceFormat: priceFormat)
            } else {

                return createPriceAndSpecialPriceFontsWithStrikethrough(priceFontStyle, specialPriceFontStyle: specialPriceFontStyle, price: price, specialPrice: specialPrice, priceFormat: priceFormat)
            }
        } else {

            // If there is only one price, then the format will be £34.00
            // If it's Grouped PLP, then the price format will be From £12.00

            let priceFormat = isGroupedPLP ? AppLocalization.sharedInstance.groupedPriceFormat : "%@"
            let priceAttrString = getPriceFontAttribute(priceFontStyle, priceFormat: priceFormat, color: AppTheme.sharedInstance.singlePriceTextColor, price: price, hasStrikethrough: false)

            return priceAttrString
        }
    }

    public static func createPriceLabelText(_ priceRange: String?, specialPriceRange: String?, price: Double?, specialPrice: Double?) -> String {

        if let priceRangeString = priceRange {
            if specialPriceRange != nil {
                // We have normal price range and special price range
                return String(format: AppSettings.sharedInstance.priceRangeFormat, priceRangeString)
            } else {
                // We have normal price range but we do not have special price range
                return String(format: AppSettings.sharedInstance.plpPriceFormat, priceRangeString)
            }
        } else if let priceDouble = price {
            // We don't have a normal price range but we do have a normal price
            let priceString = String(format: AppSettings.sharedInstance.priceDecimalFormatWithCurrency, CurrencyProvider.shared.currency.symbol, priceDouble)
            if let specialPrice = specialPrice, priceDouble != specialPrice, specialPrice > 0.0 {
                // We have a normal price and a special price
                return String(format: AppSettings.sharedInstance.priceWithSpecialPriceFormat, priceString)
            } else {
                // We have a price but we do not have a special  price
                return String(format: AppSettings.sharedInstance.priceFormat, priceString)
            }
        }
        // We don't have normal price, normal price range, special price and special price range, therefore, just return empty string
        return ""
    }

    public static func createSpecialPriceLabelText(_ priceRange: String?, specialPriceRange: String?, price: Double?, specialPrice: Double?, isClearance: Bool? = false) -> String {

        if let specialPriceRangeString = specialPriceRange {
            // We do have a normal price range and a special price range
            var specialPriceRangeFormat = AppSettings.sharedInstance.specialPriceRangeFormat
            // Check if clearance price is enabled from MB setting and also check if the API is telling us that the price is a clearance price
            if let isClearanceUnwrapped = isClearance, isClearanceUnwrapped && AppSettings.sharedInstance.isClearancePriceEnabled {
                specialPriceRangeFormat = AppSettings.sharedInstance.clearanceSpecialPriceRangeFormat
            }
            return String(format: specialPriceRangeFormat, specialPriceRangeString)
        } else if let priceUnwrapped = price {

            // We don't have a normal price range so we need to check whether the special price is different than the normal price and it's also a bigger amount
            if let specialPriceUnwrapped = specialPrice, priceUnwrapped != specialPriceUnwrapped && specialPriceUnwrapped > 0.0 {

                let specialPriceString = String(format: AppSettings.sharedInstance.priceDecimalFormatWithCurrency, CurrencyProvider.shared.currency.symbol, specialPriceUnwrapped)
                var specialPriceFormat = AppSettings.sharedInstance.specialPriceFormat
                // Check if clearance price is enabled from MB setting and also check if the API is telling us that the price is a clearance price
                if let isClearanceUnwrapped = isClearance, isClearanceUnwrapped && AppSettings.sharedInstance.isClearancePriceEnabled {
                    specialPriceFormat = AppSettings.sharedInstance.clearanceSpecialPriceFormat
                }
                return String(format: specialPriceFormat, specialPriceString)
            }
        }
        // We don't have normal price range or the special price is smaller or equal to the normal price so just return empty string.
        return ""
    }

    public static func getPriceFontAttribute(_ font: UIFont, priceFormat: String, color: UIColor, price: Double?, hasStrikethrough: Bool) -> NSMutableAttributedString {

        let priceFontDict=[NSAttributedStringKey.font: font]

        guard let price = price else {
            return NSMutableAttributedString(string: "")
        }

        var priceString = String(format: AppSettings.sharedInstance.priceDecimalFormatWithCurrency, CurrencyProvider.shared.currency.symbol, price)

        if priceFormat.range(of: "\\n") == nil {
            // Normal price formatting
            // " Was " + priceString " Was %@" =
            priceString=String(format: priceFormat, priceString)
        } else {
            // Adding a new line for the price formatting if possible
            let newPriceFormat = priceFormat.replacingOccurrences(of: "\\n", with: "\n")
            priceString=String(format: newPriceFormat, priceString)
        }

        let priceStringLength = priceString.count
        let priceAttrString = NSMutableAttributedString(string: priceString, attributes: priceFontDict)
        priceAttrString.addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: (NSRange(location: 0, length: priceStringLength)))

        if hasStrikethrough {
            for index in 0..<priceStringLength where priceAttrString.string[index] != " " {
                priceAttrString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: NSUnderlineStyle.styleSingle.rawValue, range: NSRange(location: index, length: 1))
            }
        } else {
            priceAttrString.addAttribute(NSAttributedStringKey.baselineOffset, value: NSUnderlineStyle.styleNone.rawValue, range: NSRange(location: 0, length: priceString.count))
        }

        return priceAttrString
    }

    public static func createPriceAndSpecialPriceFontsWithoutStrikethrough(_ priceFontStyle: UIFont, specialPriceFontStyle: UIFont, price: Double, specialPrice: Double, priceFormat: String) -> NSMutableAttributedString {

        let priceAttrString = getPriceFontAttribute(priceFontStyle, priceFormat: priceFormat, color: AppTheme.sharedInstance.priceTextColor, price: price, hasStrikethrough: false)

        let specialPriceAttrString = getPriceFontAttribute(specialPriceFontStyle, priceFormat: AppSettings.sharedInstance.specialPriceFormat, color: AppTheme.sharedInstance.specialPriceTextColor, price: specialPrice, hasStrikethrough: false)

        return positionSpecialPriceAndPrice(specialPriceAttrString, priceAttrString: priceAttrString, spaceFont: priceFontStyle)
    }

    public static func createPriceAndSpecialPriceFontsWithStrikethrough(_ priceFontStyle: UIFont, specialPriceFontStyle: UIFont, price: Double, specialPrice: Double, priceFormat: String) -> NSMutableAttributedString {

        let priceAttrString = getPriceFontAttribute(priceFontStyle, priceFormat: priceFormat, color: AppTheme.sharedInstance.strikethroughPriceTextColor, price: price, hasStrikethrough: false)

        let specialPriceAttrString = getPriceFontAttribute(specialPriceFontStyle, priceFormat: AppSettings.sharedInstance.specialPriceFormat, color: AppTheme.sharedInstance.specialPriceTextColor, price: specialPrice, hasStrikethrough: false)

        let fullString = positionSpecialPriceAndPrice(specialPriceAttrString, priceAttrString: priceAttrString, spaceFont: priceFontStyle)

        if AppSettings.sharedInstance.strikethroughForNormalPrice {
            var priceBegin: Int
            var priceEnd: Int

            if AppSettings.sharedInstance.isNowPriceLeftWasPriceRight {
                priceBegin = fullString.length - priceAttrString.length
                priceEnd = fullString.length
            } else {
                priceBegin = 0
                priceEnd = fullString.length - specialPriceAttrString.length
            }

            for index in priceBegin..<priceEnd where fullString.string[index] != " " {
                fullString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: NSUnderlineStyle.styleSingle.rawValue, range: NSRange(location: index, length: 1))
            }

            fullString.addAttribute(NSAttributedStringKey.baselineOffset, value: 0, range: NSRange(location: 0, length: 1))
        }

        return fullString
    }

    // Check was price and now price location.
    fileprivate static func positionSpecialPriceAndPrice(_ specialPriceAttrString: NSMutableAttributedString, priceAttrString: NSMutableAttributedString, spaceFont: UIFont) -> NSMutableAttributedString {

        let singleSpace = NSAttributedString(string: " ", attributes: [NSAttributedStringKey.font: spaceFont])

        if AppSettings.sharedInstance.isNowPriceLeftWasPriceRight {

            specialPriceAttrString.append(singleSpace)
            specialPriceAttrString.append(priceAttrString)

            return specialPriceAttrString
        } else {

            priceAttrString.append(singleSpace)
            priceAttrString.append(specialPriceAttrString)

            return priceAttrString
        }
    }

    public static func setupProductTitleLable(brand: String?,
                                            brandTextColor: UIColor = AppTheme.sharedInstance.pdpBrandLabelColor,
                                            brandFont: UIFont = AppTheme.sharedInstance.pdpBrandLabelFont,
                                            title: String?,
                                            titleTextColor: UIColor = AppTheme.sharedInstance.pdpTitleLabelColor,
                                            titleFont: UIFont = AppTheme.sharedInstance.pdpTitleLabelFont) -> NSMutableAttributedString {

        let titleAttributedString = getTitleFontAttributes(title: title,
                                                           titleTextColor: titleTextColor,
                                                           titleFont: titleFont)

        let brandAttributedString = getBrandNameFontAttributes(brand: brand,
                                                               brandTextColor: brandTextColor,
                                                               brandFont: brandFont)

        // Combine brand name and title
        brandAttributedString.append(titleAttributedString)

        return brandAttributedString
    }

    public static func getTitleFontAttributes(title: String?,
                                            titleTextColor: UIColor,
                                            titleFont: UIFont) -> NSMutableAttributedString {

        var productTitle = ""

        if let titleUnwrapped = title {

            productTitle = titleUnwrapped
        }

        // Create attributed product title
        let attributesDictionary = [NSAttributedStringKey.foregroundColor: titleTextColor,
                                    NSAttributedStringKey.font: titleFont]

        let titleAttributedString = NSMutableAttributedString(string: productTitle,
                                                              attributes: attributesDictionary)

        return titleAttributedString
    }

    public static func getBrandNameFontAttributes(brand: String?,
                                                brandTextColor: UIColor,
                                                brandFont: UIFont) -> NSMutableAttributedString {

        var productBrand = ""

        if let brandUnwrapped = brand {

            productBrand = brandUnwrapped + " "
        }

        let attributesDictionary = [NSAttributedStringKey.foregroundColor: brandTextColor,
                                    NSAttributedStringKey.font: brandFont]

        let brandAttributedString = NSMutableAttributedString(string: productBrand,
                                                              attributes: attributesDictionary)

        return brandAttributedString
    }

    public static func initSubTotalLabel(_ total: Double?) -> NSMutableAttributedString {
        guard let total = total else {
            return NSMutableAttributedString(string: "")
        }

        let subTotalFontDict = [NSAttributedStringKey.foregroundColor: AppTheme.sharedInstance.bagTotalLabelColor,
                                NSAttributedStringKey.font: AppTheme.sharedInstance.subTotalFont]

        let priceFormat = AppSettings.sharedInstance.priceDecimalFormatWithCurrency
        let subTotalAttrString = NSMutableAttributedString(string: String(format: priceFormat, CurrencyProvider.shared.currency.symbol, total), attributes: subTotalFontDict)
        return subTotalAttrString
    }

    public static func initQuantityLabel(quantity: Int, priceOfItem: Double) -> String {
        let priceFormat = "%d x " + AppSettings.sharedInstance.priceDecimalFormatWithCurrency
        let price = String(format: priceFormat, quantity, CurrencyProvider.shared.currency.symbol, priceOfItem)
        return price
    }

    public static func brandedProductLabel( _ productTitle: String, lineSpacing: Int ) -> NSMutableAttributedString {

        let grandFontDict = [NSAttributedStringKey.foregroundColor: AppTheme.sharedInstance.bagTotalWordColor,
                             NSAttributedStringKey.font: AppTheme.sharedInstance.brandedPlpTitleLabelFont] 

        let grandString: String = productTitle

        let grandAttrString = NSMutableAttributedString(string: grandString, attributes: grandFontDict)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = CGFloat(lineSpacing)
        paragraphStyle.alignment = NSTextAlignment.center
        grandAttrString.addAttribute(NSAttributedStringKey.foregroundColor, value: AppTheme.sharedInstance.brandedPlpTitleLabelColor, range: NSRange(location: 0, length: grandString.length))
        grandAttrString.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: grandString.length))

        return grandAttrString
    }

    public static func initGrandTotalLabel(_ total: Double?, discountedTotal: Double? = nil) -> NSMutableAttributedString {

        guard let total = total else {
            return NSMutableAttributedString(string: "")
        }

        let grandFontDict = [NSAttributedStringKey.foregroundColor: AppTheme.sharedInstance.bagTotalWordColor, NSAttributedStringKey.font: AppTheme.sharedInstance.totalLabelFont]

        let grandString: String = AppLocalization.sharedInstance.bagTotalText
        let grandStringLength = grandString.count

        let grandAttrString = NSMutableAttributedString(string: grandString, attributes: grandFontDict)

        grandAttrString.addAttribute(NSAttributedStringKey.foregroundColor, value: AppTheme.sharedInstance.bagTotalWordColor, range: (NSRange(location: 0, length: grandStringLength)))

        if let discountedTotalUnwrapped = discountedTotal, AppSettings.sharedInstance.showSubtotalOnBag {

            let fontColor = AppSettings.sharedInstance.strikethroughForNormalPrice ? AppTheme.sharedInstance.strikethroughPriceTextColor : AppTheme.sharedInstance.priceTextColor

            let totalAttrString = getPriceFontAttribute(AppTheme.sharedInstance.priceFont, priceFormat: " %@", color: fontColor, price: total, hasStrikethrough: AppSettings.sharedInstance.strikethroughForNormalPrice)

            grandAttrString.append(totalAttrString)

            let discountedTotalAttrString = getPriceFontAttribute(AppTheme.sharedInstance.totalFont, priceFormat: " %@", color: AppTheme.sharedInstance.bagTotalLabelColor, price: discountedTotalUnwrapped, hasStrikethrough: false)

            grandAttrString.append(discountedTotalAttrString)

        } else {

            let totalAttrString = getPriceFontAttribute(AppTheme.sharedInstance.totalFont, priceFormat: " %@", color: AppTheme.sharedInstance.bagTotalLabelColor, price: total, hasStrikethrough: false)

            grandAttrString.append(totalAttrString)
        }

        return grandAttrString
    }

    public static func initLoginHeaderPlatformLabel(title: String = AppLocalization.sharedInstance.signinTitle) -> NSMutableAttributedString {

        let fontDict = [NSAttributedStringKey.foregroundColor: AppTheme.sharedInstance.loginBigTitleLabelColor,
                                             NSAttributedStringKey.font: AppTheme.sharedInstance.loginBigTitleLabelFont]

        let attrString = NSMutableAttributedString(string: title, attributes: fontDict)

        return attrString
    }

    public static func initSignInTitleLabel() -> NSMutableAttributedString {

        let bigTitleFontDict = [NSAttributedStringKey.foregroundColor: AppTheme.sharedInstance.loginBigTitleLabelColor,
                                                     NSAttributedStringKey.font: AppTheme.sharedInstance.loginBigTitleLabelFont]
        let bigTitleAttrString = NSAttributedString(string: AppLocalization.sharedInstance.loginBigTitle, attributes: bigTitleFontDict)

        // API escapes strings so we end up having \\n instead of \n. This prevents label to render new line
        let fullTitle: String = AppLocalization.sharedInstance.signIntoTextWithNewline.replacingOccurrences(of: "\\n", with: "\n")

        let smallTitleFontDict = [NSAttributedStringKey.foregroundColor: AppTheme.sharedInstance.loginSmallTitleLabelColor,
                                  NSAttributedStringKey.font: AppTheme.sharedInstance.loginSmallTitleLabelFont] 

        let fullTitleAttrString = NSMutableAttributedString(string: fullTitle, attributes: smallTitleFontDict)

        // Combine them altogether
        fullTitleAttrString.append(bigTitleAttrString)

        return fullTitleAttrString
    }

    public static func initRegisterTitleLabel() -> NSMutableAttributedString {

        // TODO: Due to time pressure of demo, I've tried to reuse login view's title. A better approach should be taken

        let bigTitleFontDict = [NSAttributedStringKey.foregroundColor: AppTheme.sharedInstance.loginBigTitleLabelColor,
                                                     NSAttributedStringKey.font: AppTheme.sharedInstance.loginBigTitleLabelFont]
        let bigTitleAttrString = NSAttributedString(string: AppLocalization.sharedInstance.loginBigTitle, attributes: bigTitleFontDict)

        let fullTitle: String = AppLocalization.sharedInstance.signupTitle

        let smallTitleFontDict = [NSAttributedStringKey.foregroundColor: AppTheme.sharedInstance.loginSmallTitleLabelColor, NSAttributedStringKey.font: AppTheme.sharedInstance.loginSmallTitleLabelFont]

        let fullTitleAttrString = NSMutableAttributedString(string: fullTitle, attributes: smallTitleFontDict)

        // Combine them altogether
        fullTitleAttrString.append(bigTitleAttrString)

        return fullTitleAttrString
    }

    public static func initCheckoutTitleLabel() -> NSMutableAttributedString {

        let bigTitleFontDict = [NSAttributedStringKey.foregroundColor: AppTheme.sharedInstance.loginBigTitleLabelColor,
                                                     NSAttributedStringKey.font: AppTheme.sharedInstance.loginBigTitleLabelFont]
        let bigTitleAttrString = NSAttributedString(string: AppLocalization.sharedInstance.loginBigTitle, attributes: bigTitleFontDict)

        let fullTitle: String = AppLocalization.sharedInstance.signIntoTextWithoutNewline

        let smallTitleFontDict = [NSAttributedStringKey.foregroundColor: AppTheme.sharedInstance.loginSmallTitleLabelColor,
                                  NSAttributedStringKey.font: AppTheme.sharedInstance.loginSmallTitleLabelFont]

        let fullTitleAttrString = NSMutableAttributedString(string: fullTitle, attributes: smallTitleFontDict)

        // Combine them altogether
        fullTitleAttrString.append(bigTitleAttrString)

        return fullTitleAttrString
    }
    public static func showFreeForPriceZero(_ price: Double) -> String {
        return price > 0 ? price.toPriceString() : AppLocalization.sharedInstance.checkoutSelectedPaymentMethodFreeTitle
    }

    // Enable spacing on the label
    public static func enableLetterSpacing(_ spacingValue: Double = 1.0, label: UILabel?) {
        guard AppSettings.sharedInstance.enableSearchLetterSpacing else {
            return
        }

        let attributedString: NSMutableAttributedString
        if let existedAttributedString = label?.attributedText {
            attributedString = NSMutableAttributedString(attributedString: existedAttributedString)
        } else {
            attributedString = NSMutableAttributedString()
        }

        // Enable spacing
        attributedString.addAttribute(NSAttributedStringKey.kern, value: spacingValue, range: NSRange(location: 0, length: attributedString.length))
        label?.attributedText = attributedString
    }

    // Enable underline on the label
    public static func enableUnderline(_ labelText: String) -> NSAttributedString {
        let textRange = NSRange(location: 0, length: labelText.length)
        let attributedText = NSMutableAttributedString(string: labelText)
        attributedText.addAttribute(NSAttributedStringKey.underlineStyle, value: NSUnderlineStyle.styleSingle.rawValue, range: textRange)
        return attributedText
    }

    // Switching cases for text
    public static func checkCases(_ labelText: String) -> String {
        // Switching cases
        switch AppSettings.sharedInstance.shopCategoryNameCase {
        case ShopCategoryNameCaseType.Lower.rawValue:
            return labelText.lowercased()
        case ShopCategoryNameCaseType.Upper.rawValue:
            return labelText.uppercased()
        default:
            return labelText
        }
    }
}

extension UILabel {

    /**
     Fetches the current UILabel but truncates it without matching breaking word boundries
     */
    @nonobjc
    func setTruncatedText( _ text: String, forWidth width: CGFloat = -1.0 ) {

        let labelWidth = width == -1.0 ? self.frame.width : width

        guard let validText = self.text else {
            return
        }

        let words = validText.components(separatedBy: " ")
        var newText = "" as NSString
        var listedWords = 0
        if words.count > 1 {
            for word in words {

                var statement = "\(newText) \(word)" as NSString
                statement = statement.trimmingCharacters(in: CharacterSet.whitespaces) as NSString
                let size = statement.size(withAttributes: [NSAttributedStringKey.font: self.font])

                if size.width < labelWidth {
                    newText = "\(newText) \(word)" as NSString
                    listedWords += 1
                } else {
                    break
                }
            }

            if listedWords < words.count {
                newText = newText.appending(" ...") as NSString
            }

        } else {
            newText = validText as NSString
        }

        self.text = newText as String
        self.sizeToFit()
    }
}
