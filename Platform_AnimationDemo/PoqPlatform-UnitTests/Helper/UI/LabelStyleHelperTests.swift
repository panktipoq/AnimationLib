import XCTest
@testable import PoqPlatform

class LabelStyleHelperTests: XCTestCase {

    func testOnePrice() {

        let attributedString = LabelStyleHelper.initPriceLabel(15.31, specialPrice: 15.31, isGroupedPLP: false)
        let currencySymbol = CurrencyProvider.shared.currency.symbol

        XCTAssertEqual(attributedString.string, "\(currencySymbol)15.31")

        XCTAssert(checkNoStrikethrough(attributedString, inRange: 0..<attributedString.length),
                  "The price shouldn't be crossed out")

        XCTAssertEqual(attributedString.size().height, AppTheme.sharedInstance.priceFont.lineHeight, accuracy: 0.01,
                       "Check no bug on iOS 10, the price should be displayed on a single line of text")
    }

    func testFormatWithoutStrikethrough() {
        let previousSetting = AppSettings.sharedInstance.strikethroughForNormalPrice
        AppSettings.sharedInstance.strikethroughForNormalPrice = false

        let attributedString = LabelStyleHelper.initPriceLabel(123.45, specialPrice: 67.89, isGroupedPLP: false)
        let currencySymbol = CurrencyProvider.shared.currency.symbol

        XCTAssertEqual(attributedString.string, "Now \(currencySymbol)67.89  Was \(currencySymbol)123.45")

        XCTAssert(checkNoStrikethrough(attributedString, inRange: 0..<attributedString.length),
                  "When strikethroughForNormalPrice == false, the prices shouldn't be crossed out")

        XCTAssertEqual(attributedString.size().height, AppTheme.sharedInstance.priceFont.lineHeight, accuracy: 0.01,
                       "Check no bug on iOS 10, the prices should be displayed on a single line of text")

        AppSettings.sharedInstance.strikethroughForNormalPrice = previousSetting
    }

    func testFormatWithStrikethrough() {
        let previousSetting = AppSettings.sharedInstance.strikethroughForNormalPrice
        AppSettings.sharedInstance.strikethroughForNormalPrice = true

        let attributedString = LabelStyleHelper.initPriceLabel(123.45, specialPrice: 67.89, isGroupedPLP: false)
        let currencySymbol = CurrencyProvider.shared.currency.symbol

        XCTAssertEqual(attributedString.string, "Now \(currencySymbol)67.89  Was \(currencySymbol)123.45")

        XCTAssert(checkNoStrikethrough(attributedString, inRange: 0..<12),
                  "When strikethroughForNormalPrice == true, the special price shouldn't be crossed out")

        XCTAssert(checkAllStrikethrough(attributedString, inRange: 12..<15),
                  "When strikethroughForNormalPrice == true, the word 'Was' should be crossed out")

        XCTAssert(checkAllStrikethrough(attributedString, inRange: 16..<attributedString.length),
                  "When strikethroughForNormalPrice == true, the regular price should be crossed out")

        XCTAssertEqual(attributedString.size().height, AppTheme.sharedInstance.priceFont.lineHeight, accuracy: 0.01,
                       "Check no bug on iOS 10, the prices should be displayed on a single line of text")

        AppSettings.sharedInstance.strikethroughForNormalPrice = previousSetting
    }

    /// Returns true if no characters in the specified range have the strikethrough attribute
    func checkNoStrikethrough(_ string: NSAttributedString, inRange range: CountableRange<Int>) -> Bool {
        for character in range {
            if let attribute = string.attribute(NSAttributedStringKey.strikethroughStyle, at: character, effectiveRange: nil) as? NSNumber,
                attribute.intValue != 0 {
                return false
            }
        }
        return true
    }

    /// Returns true if all the characters in the specified range have the strikethrough attribute
    func checkAllStrikethrough(_ string: NSAttributedString, inRange range: CountableRange<Int>) -> Bool {
        for character in range {
            guard let attribute = string.attribute(NSAttributedStringKey.strikethroughStyle, at: character, effectiveRange: nil) as? NSNumber,
                attribute.intValue != 0 else {
                return false
            }
        }
        return true
    }
}
