import PoqPlatform
import PoqUtilities

/**
 Test the product detail page.
 
 Test that the content blocks are present, ordered, and contain their key elements. Navigate to adjacent pages.
 ![image][ProductDetailPageTests.png]
*/
class ProductDetailPageTests: ScreensTestCase {
    // bundle with the JSON files used to mock server responses
    override var resourcesBundleName: String { return "ModernMurrayCeramicVase" }
    
//    func testProductDetail() {
//        let search = SearchScreen.mockSearch(response(forJson: "SearchResult"), forName: "Modern Murray Ceramic Vase")
//        let showDetail = SearchScreen.mockProductDetail(response(forJson: "ProductDetail"))
//        
//        _ = HomeScreen(self)
//            .mock(search).search(byName: "Modern Murray Ceramic Vase")
//            .mock(showDetail).showProductDetail()
//            .swipeToNextImage()
//            .swipeToProductDescription()
//            .assertOrderedContentBlocks()
//            .assertUiElements()
//            .showDescription()
//            .back()
//            .showSizeGuide()
//            .back()
//    }
    
    /// FIXME: - This test is failing consistently for an unknown reason.
    /// The web checkout seems to be displaying 2 UIWindows when failing?!
//    func testWebCheckout()
//    {
//        let poqUserID = "*"
//        let search = SearchScreen.mockSearch(response(forJson: "SearchResult"), forName: "Modern Murray Ceramic Vase")
//        let showDetail = SearchScreen.mockProductDetail(response(forJson: "ProductDetail"))
//        let addtoBag = BagScreen.mockBag(response(forJson: "AddToBag"), poqUserId: poqUserID)
//        let showBag = BagScreen.mockShowBagContents(response(forJson: "BagContents"), poqUserId: poqUserID)
//        let checkout = CheckoutScreen.mockCheckout(response(forJson: "Checkout"), poqUserId: poqUserID)
     
//        AppSettings.sharedInstance.pdpSizeSelectorType = ProductSizeSelectorType.sheet.rawValue

//        _ = HomeScreen(self)
//            .mock(search).search(byName: "Modern Murray Ceramic Vase")
//            .mock(showDetail).showProductDetail()
//            .mock(addtoBag).addToBag()
//            .mock(showBag).showBagContents()
//            .mock(checkout).checkout()
//            .assertNonEmptyWebView()
//    }
}
