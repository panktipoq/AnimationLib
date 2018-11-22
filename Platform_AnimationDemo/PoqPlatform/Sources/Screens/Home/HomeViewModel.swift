//
//  HomeViewModel.swift
//  Poq.iOS
//
//  Created by Jun Seki on 21/01/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqNetworking

public final class HomeViewModel: PoqNetworkTaskDelegate {
    
    // MARK: - Initializers
    public var homeBanners = [PoqHomeBanner]()
    public var appStories = [PoqAppStory]()
    
    public var homeContentItems = [HomeContent]()
    
    weak var presenter: PoqPresenter?
    
    public init(presenter: PoqPresenter) {
        self.presenter = presenter
    }
    
    var hasReceivedAppStoriesResponse = false
    var hasReceivedBannersResponse = false
    
    // MARK: - Skeletons
    
    public func addAppStorySkeletons() {
        // We append 1 skeletons for app stories
        let homeBannerSkeleton = HomeContent(identifier: AppStoriesCarouselCell.poqReuseIdentifier, bannerItem: nil)
        homeContentItems.append(homeBannerSkeleton)
    }
    
    public func addSingIn() {
        homeContentItems.append(signInBanner)
    }
    
    public func addBannerSkeletons() {
        // We append 3 skeletons for banners
        let homeBannerSkeleton = HomeContent(identifier: BannerCell.poqReuseIdentifier, bannerItem: nil)
        homeContentItems.append(homeBannerSkeleton)
        homeContentItems.append(homeBannerSkeleton)
        homeContentItems.append(homeBannerSkeleton)
    }
    
    // MARK: - Fetching

    public func fetchBanners(_ isRefresh: Bool = false) {
        hasReceivedBannersResponse = false
        presenter?.update(state: .loading, networkTaskType: PoqNetworkTaskType.homeBanner, withNetworkError: nil)
        PoqNetworkService(networkTaskDelegate: self).getHomeBanners(isRefresh)
    }
    
    public func fetchAppStories() {
        hasReceivedAppStoriesResponse = false
        presenter?.update(state: .loading, networkTaskType: PoqNetworkTaskType.appStories, withNetworkError: nil)
        PoqNetworkService(networkTaskDelegate: self).getAppStories()
    }
    
    func getSettings(_ isRefresh: Bool = false) {
        PoqNetworkService(networkTaskDelegate: self).getSplash(isRefresh: isRefresh)
    }
    
    // MARK: - Basic network task callbacks
    
    public func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) { }

    public func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        if networkTaskType == PoqNetworkTaskType.splash, let splashSettings = result?.first as? PoqSplash {
            SettingParseHelper.updateAppSettingsWithSplashObject(splashSettings)
        } else {
            parseResult(result, networkTaskType: networkTaskType)
            self.presenter?.update(state: .completed, networkTaskType: networkTaskType, withNetworkError: nil)
        }
    }

    public func parseResult(_ result: [Any]?, networkTaskType: PoqNetworkTaskTypeProvider) {
        if networkTaskType == .appStories,
            let storiesResponse = result?.first as? PoqAppStoryResponse {
            hasReceivedAppStoriesResponse = true
            appStories = storiesResponse.stories
        }
        if networkTaskType == .homeBanner,
            let poqHomeBanners = result as? [PoqHomeBanner] {
            hasReceivedBannersResponse = true
            homeBanners = poqHomeBanners
        }
        // Create the banners content banners
        if let homeViewPresenter = self.presenter as? HomeViewPresenter {
            homeContentItems = createHomeContent(storyCarouselType: homeViewPresenter.storyCarouselType)
        }
    }
    
    public func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        handleError(taskType: networkTaskType)
        // Only update the presenter once everything is loaded
        if hasReceivedBannersResponse && hasReceivedAppStoriesResponse {
            self.presenter?.update(state: .error, networkTaskType: networkTaskType, withNetworkError: nil)
        }
    }
    
    public func handleError(taskType: PoqNetworkTaskTypeProvider) {
        switch taskType {
        case PoqNetworkTaskType.homeBanner:
            hasReceivedBannersResponse = true
            homeBanners.removeAll()
            remove(contentItemIdentifier: BannerCell.poqReuseIdentifier)
        case PoqNetworkTaskType.appStories:
            hasReceivedAppStoriesResponse = true
            appStories.removeAll()
            remove(contentItemIdentifier: AppStoriesCarouselCell.poqReuseIdentifier)
        default:
            break
        }
    }
    
    func remove(contentItemIdentifier: String) {
        homeContentItems = homeContentItems.filter({
            if $0.identifier == contentItemIdentifier {
                return false
            }
            return true
        })
    }
    
    // MARK: - Login banner logic
    
    var signInBanner: HomeContent {
        let homeBannerItem: HomeBannerItem
        if AppSettings.sharedInstance.useCustomisedFirstTimeBanner {
            homeBannerItem = HomeBannerItem(type: .firstTimeCustomerLogin, poqHomeBanner: nil)
        } else {
            homeBannerItem = HomeBannerItem(type: .firstTimePlatformLogin, poqHomeBanner: nil)
        }
        return HomeContent(identifier: homeBannerItem.type.cellIdentifier, bannerItem: homeBannerItem)
    }
    
    var shouldHideSignIn: Bool {
        if !AppSettings.sharedInstance.displayFirstTimeBanner {
            return true
        }
        let userDefaults = UserDefaults.standard
        let display = userDefaults.bool(forKey: "hideSignIn") as Bool
        return display
    }
    
    func updateDisplaySignIn(_ value: Bool) {
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(value, forKey: "hideSignIn")
        userDefaults.synchronize()
    }

    func removeSignInBanner() {
        homeContentItems = homeContentItems.filter({
            switch $0.bannerItem?.type {
            case .firstTimePlatformLogin?, .firstTimeCustomerLogin?:
                return false
            case .none:
                return true
            default:
                return true
            }
        })
    }

    var hasSignInBanner: Bool {
        return homeContentItems.contains {
            switch $0.bannerItem?.type {
            case .firstTimePlatformLogin?, .firstTimeCustomerLogin?:
                return true
            case .none:
                return false
            default:
                return false
            }
        }
    }
    
    // MARK: - Home banner creation
    
    func createAppStoriesContent(storyCarouselType: StoryCarouselType = .card) -> [HomeContent] {
        // First create the App Stories
        var appStoryContentItems = [HomeContent]()
        if appStories.count > 0 {
            let storiesBanner = HomeBannerItem(type: .stories(appStories: appStories, storyType: storyCarouselType), poqHomeBanner: nil)
            appStoryContentItems.append(HomeContent(identifier: storiesBanner.type.cellIdentifier, bannerItem: storiesBanner))
        } else if let item = homeContentItems.first(where: { $0.identifier == AppStoriesCarouselCell.poqReuseIdentifier && $0.bannerItem == nil }),
            (!hasReceivedAppStoriesResponse || !hasReceivedBannersResponse) {
            // Only keep showing the item if there is an item with a nil result which means that they are skeletons and we haven't loaded everything
            appStoryContentItems.append(item)
        }
        
        return appStoryContentItems
    }
    
    func createSignInContent() -> [HomeContent] {
        if !shouldHideSignIn {
            return [signInBanner]
        }
        return [HomeContent]()
    }
    
    func createBannersContent() -> [HomeContent] {
        var bannersContentItems = [HomeContent]()
        if homeBanners.count > 0 {
            for homeBanner in homeBanners {
                if let urlString = homeBanner.url, urlString.contains(".gif") {
                    let homeBannerItem = HomeBannerItem(type: .gif, poqHomeBanner: homeBanner)
                    bannersContentItems.append(HomeContent(identifier: homeBannerItem.type.cellIdentifier, bannerItem: homeBannerItem))
                } else {
                    let homeBannerItem = HomeBannerItem(type: .imageBanner, poqHomeBanner: homeBanner)
                    bannersContentItems.append(HomeContent(identifier: homeBannerItem.type.cellIdentifier, bannerItem: homeBannerItem))
                }
            }
        } else {
            let homeContentBannerItems = homeContentItems.filter({ $0.identifier == BannerCell.poqReuseIdentifier && $0.bannerItem == nil })
            if homeContentBannerItems.count > 0, (!hasReceivedAppStoriesResponse || !hasReceivedBannersResponse) {
                // If there is an item it means that there were some skeletons
                for homeContent in homeContentBannerItems {
                    bannersContentItems.append(homeContent)
                }
            }
        }
        return bannersContentItems
    }
    
    func createHomeContent(storyCarouselType: StoryCarouselType = .card) -> [HomeContent] {
        return createAppStoriesContent(storyCarouselType: storyCarouselType) + createSignInContent() + createBannersContent()
    }
}
