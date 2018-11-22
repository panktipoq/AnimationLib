//
//  LookbookViewController.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 14/04/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import Haneke
import PoqNetworking

open class LookbookViewController: PoqBaseViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    // MARK: Attributes

    open var lookbookId: Int = 0
    open var lookbookTitle: String = ""
    open var viewModel: LookbookViewModel?
    open var lookbookImageViews: [LookbookImageView] = []
    open var source: String?

    var currentIndex: Int = 0 {
        didSet {
            currentIndexChanged()
        }
    }

    open override var prefersStatusBarHidden: Bool {
        return true
    }

    // MARK: IBOutlets
    @IBOutlet open weak var collectionView: UICollectionView! {
        didSet {
            registerPoqCells()
        }
    }

    @IBOutlet weak var prevButton: PreviousButton?
    @IBOutlet weak var nextButton: NextButton?

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.hidesBottomBarWhenPushed = true
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle:nibBundleOrNil)

        self.hidesBottomBarWhenPushed = true
    }

    open func registerPoqCells() {
        collectionView.registerPoqCells(cellClasses: [LookbookImageCell.self])
    }

    // MARK: View Delegates

    override open func viewDidLoad() {
        super.viewDidLoad()

        //set up back button until lookbook loaded

        let closeButton = NavigationBarHelper.setupCloseButtonWithCircleBackground()
        closeButton.addTarget(self, action: #selector(closeButtonClicked), for: .touchUpInside)
        view.addSubview(closeButton)

        // Set empty title on navbar
        self.navigationItem.titleView = nil

        self.navigationItem.rightBarButtonItem = nil
        let clearView: UIView = UIView(frame: CGRect.zero)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: clearView)

        // Set viewmodel for networking
        self.viewModel = LookbookViewModel(viewControllerDelegate: self)

        self.prevButton?.isHidden = false
        self.nextButton?.isHidden = false

        // Track lookbook open
        PoqTrackerHelper.trackLookBookOpen(PoqTrackerActionType.Title, label: lookbookTitle)

        self.viewModel!.getLookbookImages(self.lookbookId, isRefresh: false)

        // test support
        self.view.accessibilityIdentifier = AccessibilityLabels.lookBookView
    }

    // Hide bars
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        hideNavigationBarBackground(true)
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        hideNavigationBarBackground(true)
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // set back navigation bar background
        hideNavigationBarBackground(false)
    }

    // Show bars
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        //self.hideBars(false)

        if isMovingFromParentViewController {

            //NavigationHelper.sharedInstance.lookbook = nil

            let cache = Shared.imageCache
            if let lookbookImages = viewModel?.lookbookImages {

                for lookbookImage in lookbookImages {

                    if let lookbookImageURL = lookbookImage.url {

                        cache.remove(key: lookbookImageURL)
                    }
                }
            }
        }
    }

    // MARK: - Collection view delegates

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel!.lookbookImages.count
    }

    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        currentIndex = Int(collectionView.contentOffset.x / collectionView.frame.size.width)
    }

    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: LookbookImageCell = collectionView.dequeueReusablePoqCell(forIndexPath: indexPath)
        let index = indexPath.item

        var lookbookImageView: LookbookImageView?

        if lookbookImageViews.count > index {
            let lookbookImageCreated = lookbookImageViews[index]
            lookbookImageCreated.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            lookbookImageCreated.autoresizesSubviews = true

            lookbookImageView = lookbookImageCreated
        } else {
            // Requested item is not created yet
            // We will init and save it to viewControllers
            // So it can be recycled
            if let newLookbookImageView = LookbookImageView.createLookbookImageView() {
                newLookbookImageView.lookbookImage = viewModel!.lookbookImages[index]
                newLookbookImageView.viewControllerDelegate = self
                newLookbookImageView.lookbookTitle = lookbookTitle
                newLookbookImageView.screenNumber = index

                lookbookImageViews.insert(newLookbookImageView, at: index)
                lookbookImageView = newLookbookImageView
            }
        }

        if let lookbookImageView = lookbookImageView {
            cell.setupView(lookbookImageView)
        }

        return cell
    }

    func currentIndexChanged() {
        prevButton?.isHidden = currentIndex <= 0
        nextButton?.isHidden = currentIndex >= viewModel!.lookbookImages.count - 1
    }

    // MARK: - Networking

    override open func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        // Hide controls
        prevButton?.isHidden = true
        nextButton?.isHidden = true
        collectionView?.isHidden = true
    }

    override open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        if networkTaskType == PoqNetworkTaskType.lookbookImages {
            if viewModel!.lookbookImages.count > 0 {
                // Set swipe view
                collectionView.isHidden = false
                collectionView.reloadData()

                // Hide prev for the first image
                prevButton?.isHidden = true

                // Also hide next if only 1 image available
                nextButton?.isHidden = viewModel!.lookbookImages.count == 1
            } else {
                lookbookUnavailableAlert()
            }
        }
    }

    func lookbookUnavailableAlert() {
        let title = "Sorry"
        let message = "Some of the lookbook images are not available.\nPlease try again later."

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))

        present(alert, animated: true, completion: nil)
    }

    override open func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        // Hide controls
        prevButton?.isHidden = true
        nextButton?.isHidden = true
        collectionView?.isHidden = true

        super.networkTaskDidFail(networkTaskType, error: error)
    }

    // MARK: - Utility

    // Go to previous item
    @IBAction open func previousButtonClicked() {
        let indexPath = IndexPath(item: currentIndex - 1, section: 0)
        collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
    }

    // Go to next item
   @IBAction open func nextButtonClicked() {
        let newIndex = currentIndex + 1

        guard newIndex < viewModel!.lookbookImages.count else {
            return
        }

        let indexPath = IndexPath(item: newIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
    }

    // Show/hide navigtaion bar background
    func hideNavigationBarBackground(_ hidden: Bool) {
        navigationController?.isNavigationBarHidden = hidden
        UIApplication.shared.isStatusBarHidden = hidden
    }

    /* Although close button is used for modals,
     * due to other complications of Lookbook, we push it instead of modal
     * and we use close button. So its click handler needs to be overridden.
     */
    override open func closeButtonClicked() {
        navigationController?.isNavigationBarHidden = false
        _ = navigationController?.popViewController(animated: true)
    }
}
