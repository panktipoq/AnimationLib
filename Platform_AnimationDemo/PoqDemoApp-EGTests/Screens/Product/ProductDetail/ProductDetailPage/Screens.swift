import UIKit
import EarlGrey
import XCTest

@testable import PoqNetworking
@testable import PoqPlatform
import PoqUtilities
import Swifter

extension XCTestCase: UITest {}

struct MockedRequest {
    let handler: ((HttpRequest) -> HttpResponse)
    let method: HTTPMethod
    let path: String
}

class ScreensTestCase: XCTestCase {
    
    override class func setUp() {
        MockServer.reset()
        UIView.setAnimationsEnabled(false)
        Log.level = .warn
        ScreensTestCase.skipOnboarding()
    }
    
    override class func tearDown() {
        UIView.setAnimationsEnabled(true)
        MockServer.reset()
    }
    
    override func setUp() {
        super.setUp()
        // Load the splash → download mocked mightybot settings → load home
        MockServer.shared["/splash/ios/*/3"] = response(forJson: "Splash", inBundle: "EGTestCase")
        UIApplication.shared.delegate?.window??.rootViewController = SplashViewController(nibName: "SplashViewController", bundle: nil)
        EGHelpers.assert(accessibilityID: AccessibilityLabels.search, timeout: 5.0) // Waits for home to appear
        // At this point mightybot settings are loaded, overwriting the values in AppLocalization.
    }
    
    private static func skipOnboarding() {
        UserDefaults.standard.set(true, forKey: OnboardingShownStatusDefaultsKey)
    }
}

class Screen {
    
    let test: XCTestCase
    init(_ test: XCTestCase) {
        self.test = test
    }
    
    func mock(_ mock: MockedRequest) -> Self {
        Log.warning("Mocking \(mock.path)")
        MockServer.shared[mock.path] = mock.handler
        return self
    }
}

class HomeScreen: Screen {
    
    // Search product by name
    func search(byName name: String) -> SearchScreen {
        return SearchScreen(test).search(byName: name)
    }
}

class SearchScreen: Screen {
    
    // Product detail, go to product detail
    func showProductDetail() -> DetailScreen {
        test.onView(with: .type(UICollectionViewCell.self)).atIndex(0).tap()
        test.wait(forDuration: 0.5)
        return DetailScreen(test)
    }
    
    // Product search, search by product name
    func search(byName name: String) -> Self {
        let searchPlaceholderText = AppLocalization.sharedInstance.searchPlaceholderText
        test.onView(with: .text(searchPlaceholderText)).tap()
        let enter = "\n"
        test.onView(with: .type(UITextField.self)).replace(name)
        test.onView(with: .type(UITextField.self)).type(enter)
        
        test.wait(forDuration: 0.5)
        
        return self
    }
}

class DetailScreen: Screen {
    
    func addToBag() -> BagScreen {
        return BagScreen(test).addToBag()
    }
    
    func swipeToNextImage() -> Self {
        test.onView(with: .type(PoqProductImageView.self)).swipeFastLeft()
        return self
    }
    
    func swipeToProductDescription() -> Self {
        test.onView(with: .type(PoqProductInfoContentBlockView.self)).swipeFastUp()
        return self
    }
    
    func showDescription() -> DescriptionScreen {
        test.onView(with: .type(PoqProductDescriptionContentBlockView.self)).tap()
        test.wait(forDuration: 0.5)
        return DescriptionScreen(test)
    }
    
    func showSizeGuide() -> SizeGuideScreen {
        test.onView(with: .type(PoqProductLinkContentBlockView.self)).tap()
        test.wait(forDuration: 0.5)
        return SizeGuideScreen(test)
    }
    
    func assertUiElements() -> Self {
        [
            AccessibilityLabels.likeButton,
            AccessibilityLabels.backButton,
            AccessibilityLabels.pdpAddToBag,
            AccessibilityLabels.pdpTitle,
            AccessibilityLabels.pdpPrice,
            AccessibilityLabels.pdpPageControl,
            AccessibilityLabels.pdpDescription,
            AccessibilityLabels.pdpSizes,
            AccessibilityLabels.pdpSizeGuide,
            AccessibilityLabels.pdpShare
            ].forEach { (identifier: String) in
                test.onView(with: .accessibilityIdentifier(identifier)).assertIsVisible()
        }
        let productImages = EGHelpers.count(matcher: grey_accessibilityID(AccessibilityLabels.pdpImage))
        GREYAssert(productImages > 0 )
        return self
    }
    
    func assertOrderedContentBlocks() -> Self {
        let cells = [
            PoqProductInfoContentBlockView.self,
            PoqProductDescriptionContentBlockView.self,
            PoqProductSizesContentBlockView.self,
            PoqProductLinkContentBlockView.self,
            PoqRecentlyViewedContentBlockCell.self,
            PoqProductShareContentBlockView.self
        ]
        for i in 0...cells.count - 1 {
            test.onView(with: .type(cells[i])).atIndex(UInt(i))
        }
        return self
    }
}

class BagScreen: Screen {
    
    func checkout() -> CheckoutScreen {
        return CheckoutScreen(test).checkout()
    }
    
    // Bag a product, click add to bag, tap first size available
    func addToBag() -> Self {
        
        let addToBagButtonText = AppLocalization.sharedInstance.addToBagButtonText
        test.onView(with: .title(addToBagButtonText)).tap()
        EarlGrey.selectElement(with: grey_kindOfClass(ProductSizeTableViewCell.self)).atIndex(0).tap()
        guard EGHelpers.wait(forMatcher: grey_kindOfClass(TabBarBadgeView.self), timeout: 3) else {
            GREYFail("Expected the bag tab to show a badge. Did the tap added an element?")
            return self
        }
        return self
    }
    
    // Product list, click the bag tab
    func showBagContents() -> Self {
        
        test.wait(forDuration: 1.0)
        let tabTitle3 = AppLocalization.sharedInstance.tabTitle3
        test.onView(with: .text(tabTitle3)).tap()
        return self
    }
}

class CheckoutScreen: Screen {
    
    // Checkout, assert non empty web view
    func checkout() -> Self {
        let checkout = AppLocalization.sharedInstance.checkoutButtonText
        guard EGHelpers.wait(forMatcher: grey_buttonTitle(checkout), timeout: 5.0) else {
            GREYFail("Expected an interactive checkout button. Is there something in the bag?")
            return self
        }
        EarlGrey.selectElement(with: grey_buttonTitle(checkout)).tap()
        return self
    }
    
    func assertNonEmptyWebView() {
        EGHelpers.assert(type: UIWebView.self, timeout: 5.0)
        test.onView(with: .type(UIWebView.self)).assert(with: grey_sufficientlyVisible())
        if let keyWindow = UIApplication.shared.keyWindow, let webView: UIWebView = (keyWindow.subviews.filter { $0 is UIWebView }).first as? UIWebView {
            guard let length = webView.stringByEvaluatingJavaScript(from: "document.getElementsByTagName('body')[0].innerHTML.length"), (Int(length) ?? 0) > 0 else {
                GREYFail("Expected a non empty web view.")
                return
            }
        }
    }
}

class DescriptionScreen: Screen {
    
    func back() -> DetailScreen {
        test.onView(with: .accessibilityIdentifier(AccessibilityLabels.backButton)).tap()
        test.wait(forDuration: 0.5)
        return DetailScreen(test)
    }
    
    func close() -> DetailScreen {
        test.onView(with: .type(CloseButton.self)).tap()
        test.wait(forDuration: 0.5)
        return DetailScreen(test)
    }
}

class SizeGuideScreen: Screen {
    
    func back() -> DetailScreen {
        test.onView(with: .accessibilityIdentifier(AccessibilityLabels.backButton)).tap()
        test.wait(forDuration: 0.5)
        return DetailScreen(test)
    }
}

// MOCKS

extension SearchScreen {
    
    // Mock the detail of a product: GET https://poqplatformuat.azure-api.net/products/detail/173/13566408?externalId=437&poqUserId=036752D6-F026-434E-AB99-4511BEBC731F
    static func mockProductDetail(_ handler: @escaping ((HttpRequest) -> HttpResponse)) -> MockedRequest {
        return MockedRequest(handler: handler, method: HTTPMethod.GET, path:  "/products/detail/167/*")
    }
    // Mock a keyword search: GET https://poqplatformuat.azure-api.net/products/filter/173?keyword=Modern20Murray20Ceramic20Vase&order=date&page=1
    static func mockSearch(_ handler: @escaping ((HttpRequest) -> HttpResponse), forName name: String) -> MockedRequest {
        let escapeSpaces: (String, String) -> (String) = { name, char in
            name.replacingOccurrences(of: " ", with: char)
        }
        let path = "/products/filter/167?keyword=\(escapeSpaces(name, "%20"))&order=date&page=1"
        return MockedRequest(handler: handler, method: HTTPMethod.GET, path: path)
    }
}

extension BagScreen {
    
    // Add product to the bag: POST https://poqplatformuat.azure-api.net/BagItems/173/036752D6-F026-434E-AB99-4511BEBC731F
    static func mockBag(_ handler: @escaping ((HttpRequest) -> HttpResponse), poqUserId: String) -> MockedRequest {
        return MockedRequest(handler: handler, method: HTTPMethod.POST, path: "/BagItems/167/\(poqUserId)")
    }
    // Show bag contents: GET https://poqplatformuat.azure-api.net/BagItems/173/036752D6-F026-434E-AB99-4511BEBC731F
    static func mockShowBagContents(_ handler: @escaping ((HttpRequest) -> HttpResponse), poqUserId: String) -> MockedRequest {
        return MockedRequest(handler: handler, method: HTTPMethod.GET, path: "/BagItems/167/\(poqUserId)")
    }
}

extension CheckoutScreen {
    
    // Mock a new checkout: POST http://localhost:50100/CartTransfer/apps/173/Begin?poqUserId=FA9EC37E-94B2-48A7-8B81-4A886A9D3B89
    static func mockCheckout(_ handler: @escaping ((HttpRequest) -> HttpResponse), poqUserId: String) -> MockedRequest {
        return MockedRequest(handler: handler, method: HTTPMethod.POST, path: "/CartTransfer/apps/173/*")
    }

    // Mock the old checkout: POST http://localhost:50100/order/173?poqUserID=FA9EC37E-94B2-48A7-8B81-4A886A9D3B89
    static func mockOldCheckout(_ handler: @escaping ((HttpRequest) -> HttpResponse), poqUserId: String) -> MockedRequest {
        return MockedRequest(handler: handler, method: HTTPMethod.POST, path: "/order/173?poqUserID=\(poqUserId)")
    }
}
