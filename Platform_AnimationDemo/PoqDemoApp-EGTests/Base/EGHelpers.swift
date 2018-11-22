import EarlGrey
import Foundation

struct EGHelpers {
    /**
     Count the number of elements for the given matcher.
     Example: count the number of cells of a given type.
     ```
     let countOfTableViewCells = count(matcher: grey_kindOfClass(ProductSizeTableViewCell.self))
     ```
     */
    static func count(matcher: GREYMatcher!) -> Int {
        var error: NSError? = nil
        var index: Int = 0
        let matchesBlock: MatchesBlock = { (element: Any?) -> Bool in
            if matcher.matches(element) {
                index += 1
            }
            return false
        }
        let descriptionBlock: DescribeToBlock = { (description: AnyObject?) in
            let greyDescription: GREYDescription = description as! GREYDescription
            greyDescription.appendText("Count of Matcher")
        }
        let countMatcher: GREYElementMatcherBlock = GREYElementMatcherBlock.matcher(matchesBlock: matchesBlock, descriptionBlock: descriptionBlock)
        EarlGrey.selectElement(with: countMatcher).assert(with: grey_notNil(), error: &error)
        return index
    }
    
    /**
     Count the number of visible elements for the given matcher.
     Example: count the number of visible labels of a given accessibilityId.
     Note: this will only work for elements of type UIView
     ```
     let countOfVisisbleLowStockLabels = count(matcher: grey_accessibilityID(AccessibilityLabels.lowStock))
     ```
     */
    static func countVisible(matcher: GREYMatcher!) -> Int {
        var error: NSError? = nil
        var index: Int = 0
        let matchesBlock: MatchesBlock = { (element: Any) -> Bool in
            if matcher.matches(element), let view = element as? UIView, !view.isHidden {
                index += 1
            }
            return false
        }
        let descriptionBlock: DescribeToBlock = { (description: AnyObject?) in
            let greyDescription: GREYDescription = description as! GREYDescription
            greyDescription.appendText("Count of Matcher")
        }
        let countMatcher: GREYElementMatcherBlock = GREYElementMatcherBlock.matcher(matchesBlock: matchesBlock, descriptionBlock: descriptionBlock)
        EarlGrey.selectElement(with: countMatcher).assert(with: grey_notNil(), error: &error)
        return index
    }
    
    /** Wait for the type to appear. Fails after 'timeout' seconds. */
    static func assert(type: AnyClass, timeout seconds: CFTimeInterval) {
        guard EGHelpers.wait(forMatcher: grey_kindOfClass(type), timeout: seconds) else {
            GREYFail("Couldn’t find the type \(type) in \(seconds) seconds")
            return
        }
    }
    
    /** Wait for the accessibilityID to appear. Fails after 'timeout' seconds. */
    static func assert(accessibilityID: String, timeout seconds: CFTimeInterval) {
        guard EGHelpers.wait(forMatcher: grey_accessibilityID(accessibilityID), timeout: seconds) else {
            GREYFail("Couldn’t find the accessibilityID \(accessibilityID) in \(seconds) seconds")
            return
        }
    }
    
    /** Wait for the button title to appear. Fails after 'timeout' seconds. */
    static func assert(title: String, timeout seconds: CFTimeInterval) {
        guard EGHelpers.wait(forMatcher: grey_buttonTitle(title), timeout: seconds) else {
            GREYFail("Couldn’t find the accessibilityID \(title) in \(seconds) seconds")
            return
        }
    }
    
    /**
     Returns true if the element for the given matcher becomes non nil within 'timeout' seconds.
     Example: wait 5 seconds for an accessibility id.
     ```
     EGHelpers.wait(forMatcher: grey_accessibilityID(AccessibilityLabels.Search), timeout: 5.0)
     ```
     */
    static func wait(forMatcher matcher: GREYMatcher, timeout seconds: CFTimeInterval) -> Bool {
        let isFound = GREYCondition(name: "Wait for matcher \(matcher)", block: { () -> Bool in
            var errorOrNil: NSError?
            EarlGrey.selectElement(with: matcher).assert(grey_notNil(), error: &errorOrNil)
            return errorOrNil == nil
        }).wait(withTimeout: seconds)
        return isFound
    }
    
    static func checkIsHiddenViewActionBlock() -> GREYActionBlock {
        return GREYActionBlock.action(withName: "checkHiddenBlock") { (element, errorOrNil) -> Bool in
            // Check if the found element is hidden or not.
            if let view = element as? UIView {
                return (view.isHidden == true)
            }
            return false
        }
    }
}
