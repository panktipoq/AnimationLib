//
//  PoqDemoModule.swift
//  PoqDemoApp
//
//  Created by Balaji Reddy on 09/03/2018.
//
import PoqPlatform
import PoqModuling
import Foundation

class PoqDemoModule: PoqModule {
    
    public static var appStoryCarouselType: StoryCarouselType = .card
    
    /// bundle, where nib and other resources will be searched
    var bundle: Bundle {
        return Bundle.main
    }
    
    /// Application starts from tab bar. Every item in tab bar defined by name
    /// On start(and may be later) we need resovle view controler by name
    func createViewController(forName name: String) -> UIViewController? {
        
        if case TabBarItems.home.rawValue = name {
            let homeViewController = HomeViewController(nibName: "HomeView", bundle: nil)
            homeViewController.storyCarouselType = PoqDemoModule.appStoryCarouselType
            return homeViewController
        }
        
        return nil
    }
    
    func setupApplication() {
        // Enable ratings in PDP
        PoqProductInfoContentBlockView.showRatings = true
    }
}
