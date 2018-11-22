//
//  ProductInfoContentBlockView.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Mahmut Canga on 24/12/2016.
//
//

import Foundation
import PoqNetworking
import PoqUtilities
import UIKit

open class PoqProductInfoContentBlockView: FullWidthAutoresizedCollectionCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PoqProductDetailCell {
        
    // MARK: - IBOutlets
    
    @IBOutlet open weak var imagesCollectionView: UICollectionView?
    @IBOutlet weak var imagesPageControl: UIPageControl? {
        didSet {
            imagesPageControl?.isAccessibilityElement = true
            imagesPageControl?.accessibilityIdentifier = AccessibilityLabels.pdpPageControl
        }
    }
    @IBOutlet open weak var titleLabel: UILabel? {
        didSet {
            titleLabel?.isAccessibilityElement = true
            titleLabel?.accessibilityIdentifier = AccessibilityLabels.pdpTitle
        }
    }
    @IBOutlet open weak var priceLabel: UILabel? {
        didSet {
            priceLabel?.isAccessibilityElement = true
            priceLabel?.accessibilityIdentifier = AccessibilityLabels.pdpPrice
        }
    }
    @IBOutlet open weak var addToBagButton: UIButton? {
        didSet {
            addToBagButton?.isAccessibilityElement = true
            addToBagButton?.accessibilityIdentifier = AccessibilityLabels.pdpAddToBag
        }
    }
    @IBOutlet open weak var likeButton: UIButton? {
        didSet {
            likeButton?.isAccessibilityElement = true
            likeButton?.accessibilityIdentifier = AccessibilityLabels.likeButton
        }
    }
    @IBOutlet open weak var ratingsContainerView: UIView?
    @IBOutlet open weak var starRatingView: StarRatingView?
    @IBOutlet open var ratingsLabel: UILabel?
    @IBOutlet public weak var separator: SolidLine?
    
    // MARK: - Properties
    
    /**
     This property toggles showing of `Rating Stars` and `Number Of Ratings` on PDP. They will only be shown if there is at least one rating. Defaults to false.
     */
    public static var showRatings = false
    
    open var product: PoqProduct?
    weak open var presenter: PoqProductBlockPresenter?
    
    private var imageViewContentMode: UIViewContentMode = .scaleAspectFit
    
    // MARK: - AutoLayoutMethods
    
    override open func awakeFromNib() {
        
        super.awakeFromNib()
        
        accessibilityIdentifier = AccessibilityLabels.productBasicDetail
        likeButton?.configurePoqButton(style: ResourceProvider.sharedInstance.clientStyle?.likeButtonStyle)
    }
    
    // TODO: The sizing of the info card cell should be down to the view controller, rather than the cell itself!
    /// This method is always called after setup method (cell creation)
    open override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        
        let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        
        var frame = attributes.frame
        
        // Override attributed witdh with bounds decided from super view
        frame.size.width = UIScreen.main.bounds.width
        
        var infoCardHeight = UIScreen.main.bounds.size.height
        infoCardHeight -= CGFloat(50.0) // Subtract tab bar height
        
        if DeviceType.IS_IPHONE_X {
            infoCardHeight -= CGFloat(34.0) // Subtract bottom safe area height for iPhone X
        }
        
        // TODO: Calculate color picker height to adjust final height
        
        frame.size.height = infoCardHeight
        attributes.frame = frame
        return attributes
    }
    
    // MARK: - ContentSetup
    
    open func setup(using content: PoqProductDetailContentItem, with product: PoqProduct?) {
        
        guard let productValidated = product else {
            
            Log.error("Product data is not found. Cell setup is skipped")
            return
        }
        
        self.product = product
        
        if let contentItem = (content as? PoqProductDetailCellType), case let PoqProductDetailCellType.info(imageViewContentMode) = contentItem {
            self.imageViewContentMode = imageViewContentMode
        }
        
        setupTitle(with: productValidated)
        setupPrice(with: productValidated)
        setupImagesCarousel(with: productValidated)
        setupImagesPageControl(with: productValidated)
        setupLikeButton(with: productValidated)
        setupAddToBagButton(using: productValidated)
        setupStartRatingView(using: productValidated)
    }
    
    open func setupStartRatingView(using product: PoqProduct) {
        guard let rating = product.rating, PoqProductInfoContentBlockView.showRatings == true, rating > 0 else {
            ratingsContainerView?.isHidden = true
            // Backward compatibility to hide the star rating view
            starRatingView?.isHidden = true
            return
        }
        
        // Ratings container view
        ratingsContainerView?.isHidden = false
        starRatingView?.isHidden = false
        
        // Star rating view
        starRatingView?.rating = Float(rating)
        
        // Ratings label
        ratingsLabel?.text = product
            .numberOfReviews
            .flatMap { numberOfReviews -> String? in
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .decimal
                numberFormatter.usesGroupingSeparator = true
                numberFormatter.locale = Locale.current
                return numberFormatter.string(from: NSNumber(value: numberOfReviews))
            }
            .map { "(\($0))" }
        
        // Tap gesture recognizer
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ratingsContainerViewTapGestureHandler))
        ratingsContainerView?.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func ratingsContainerViewTapGestureHandler() {
        guard let productID = product?.id else {
            return
        }
        
        NavigationHelper.sharedInstance.loadReviews(productID, isModal: true)
    }
    
    open func setupTitle(with product: PoqProduct) {
        
        titleLabel?.attributedText = LabelStyleHelper.setupProductTitleLable(brand: product.brand,
                                                                             title: product.title)
    }
    
    open func setupPrice(with product: PoqProduct) {
        
        guard let priceLabelValidated = priceLabel else {
            
            Log.error("Price label is not initialised.")
            return
        }
        
        priceLabelValidated.attributedText = LabelStyleHelper.initPriceLabel(product.price, specialPrice: product.specialPrice, priceFormat: AppSettings.sharedInstance.pdpPriceFormat)
        
        priceLabelValidated.font = UIFont(name: priceLabelValidated.font.fontName, size: CGFloat(AppSettings.sharedInstance.pdpPriceFontSize))
    }
    
    func setupImagesCarousel(with product: PoqProduct) {
        
        imagesCollectionView?.dataSource = self
        imagesCollectionView?.delegate = self
        imagesCollectionView?.backgroundColor = UIColor.white
        imagesCollectionView?.isPagingEnabled = true
        imagesCollectionView?.registerPoqCells(cellClasses: [PoqProductImageView.self])
        
        imagesCollectionView?.reloadData()
    }
    
    func setupImagesPageControl(with product: PoqProduct) {
        
        guard let productPicturesCount = product.productPictures?.count else {
            return
        }
       
        imagesPageControl?.numberOfPages = productPicturesCount
        imagesPageControl?.tintColor = AppTheme.sharedInstance.pdpPageControlTintColor
        imagesPageControl?.currentPageIndicatorTintColor = AppTheme.sharedInstance.pdpPageControlCurrentTintColor
        imagesPageControl?.addTarget(self, action: #selector(changePage(sender:)), for: UIControlEvents.valueChanged)

        if productPicturesCount > 1 {
            imagesPageControl?.isHidden = !AppSettings.sharedInstance.enablePageControl
        }
    }
    
    func setupLikeButton(with product: PoqProduct) {

        likeButton?.isSelected = product.id.flatMap { WishlistController.shared.isFavorite(productId: $0) } ?? false
    }
    
    open func setupAddToBagButton(using product: PoqProduct) {
        
        addToBagButton?.configurePoqButton(style: ResourceProvider.sharedInstance.clientStyle?.pdpAddToBagButtonStyle)
        addToBagButton?.layer.cornerRadius = CGFloat(AppTheme.sharedInstance.pdpAddToBagButtonCornerRadius)
        
        addToBagButton?.setTitle(AppLocalization.sharedInstance.pdpSoldOutMessage, for: .disabled)
        addToBagButton?.setTitle(AppLocalization.sharedInstance.addToBagButtonText, for: .normal)
        
        addToBagButton?.isEnabled = true
        
        if let productSizes = product.productSizes, productSizes.count == 0 {
            
            addToBagButton?.isEnabled = false
        }
    }
    
    // MARK: - ContentUpdate
    
    public func updateWishlistIcon() {
        guard let product = product else {
            return
        }
        
        setupLikeButton(with: product)
    }
    
    // MARK: - ActionListeners
    
    @IBAction open func likeButtonDidTap(_ sender: AnyObject) {
        
        guard let likeButtonValidated = likeButton else {
            
            Log.error("Like button does not exist?!. Can not add to wishlist")
            return
        }
        
        guard let validatedProduct = product else {
            
            Log.error("Product data missing. Can not add to wishlist")
            return
        }
        
        guard let validatedProductId = validatedProduct.id else {
            
            Log.error("Product Id missing. Can not add to wishlist")
            return
        }
        
        if likeButtonValidated.isSelected {
            
            WishlistController.shared.remove(productId: validatedProductId)
        } else {
            
            WishlistController.shared.add(product: validatedProduct)
        }
        
        likeButtonValidated.isSelected = !likeButtonValidated.isSelected
        
        presenter?.likeDidTap()
    }
    
    @IBAction func addToBagButtonDidTap(_ sender: AnyObject) {
        
        Log.verbose("Add to Bag Button Tap")
        presenter?.addToBagDidTap()
    }
    
    @objc func changePage(sender: UIPageControl) {
        imagesCollectionView?.scrollToItem(at: IndexPath(item: sender.currentPage, section: 0), at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
    }
    
    // MARK: - ImageCarousel
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let productPicturesCount = product?.productPictures?.count else {
            
            return 0
        }
        
        return productPicturesCount
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell: PoqProductImageView = collectionView.dequeueReusablePoqCell(forIndexPath: indexPath)

        guard let productPicture = product?.productPictures?[indexPath.item] else {

            assertionFailure("Can't prepare PoqProductImageView, product?.productPictures?[\(indexPath.item)] is nil.")
            return cell
        }

        guard let pictureURLValue = productPicture.url, let pictureURL = URL(string: pictureURLValue) else {

            assertionFailure("Can't prepare PoqProductImageView, productPicture.url is nil or invalid.")
            return cell
        }

        cell.imageView?.fetchImage(from: pictureURL, shouldDisplaySkeleton: false, placeholder: nil, format: nil, isAnimated: true, showLoading: true, completion: { (image) in
            if let imageView = cell.imageView, let image = image {
                self.presenter?.animationParams = AddToBagAnimationParams(productImage: image, productImageFrame: imageView.frame)
            }
        })
        cell.imageView?.contentMode = imageViewContentMode
        cell.isAccessibilityElement = true
        cell.accessibilityIdentifier = AccessibilityLabels.pdpImage
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return collectionView.frame.size
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard let pageWidth = imagesCollectionView?.frame.size.width else {
            
            return
        }
        
        imagesPageControl?.currentPage = Int(scrollView.contentOffset.x / pageWidth)
        
        Log.verbose("Swipe view: Index \(String(describing: imagesPageControl?.currentPage))")
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        Log.verbose("Swipe view: Selected \(index)")
        
        guard let imageCell = collectionView.cellForItem(at: indexPath) as? PoqProductImageView else {
            
            Log.error("Can not get collectionView cell at index \(indexPath.row)")
            return
        }
        
        guard let imageView = imageCell.imageView else {
            
            Log.error("Can not get imageView cell at index \(indexPath.row)")
            return
        }
        
        presenter?.imageDidTap(at: indexPath, forImageView: imageView)
    }
}
