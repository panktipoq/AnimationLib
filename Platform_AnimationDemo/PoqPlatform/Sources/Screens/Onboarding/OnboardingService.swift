//
//  OnboardingService.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Nikolay Dzhulay on 29/12/2016.
//
//

import Foundation
import PoqNetworking

/// Structure to animate color between pages
/// For each page with have its own color
public struct ColorPoint {
    
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat
    let alpha: CGFloat
    let boundsX: CGFloat
    
    static func colorPoints(for pages: [PoqOnboarding]) -> [ColorPoint] {
        let pageWidth = UIScreen.main.bounds.size.width
        
        var colorPoints = [ColorPoint]()
        for i in 0..<pages.count {
            let page: PoqOnboarding = pages[i]
            var pageColor = UIColor.white
            if let backgroundColorHex = page.backgroundColorHex {
                pageColor = UIColor.hexColor(backgroundColorHex)
            }
            
            let colorPoint = ColorPoint(color: pageColor, boundsX: pageWidth * CGFloat(i))
            colorPoints.append(colorPoint)
        }
        return colorPoints
    }
    
    init(color: UIColor, boundsX: CGFloat) {
        self.boundsX = boundsX
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        red = r
        green = g
        blue = b
        alpha = a
    }
    
}

/**
 Describe general API of Onboarding date provider
 */
public protocol OnboardingService: PoqNetworkTaskDelegate {
    
    var presenter: PoqOnboardingPresenter? { get set }
    
    /// array of onboarding pages, will be empty while data is loading
    var pages: [PoqOnboarding] { get set }
    
    var colorPoints: [ColorPoint] { get set }
    
    /**
     Request onboarding data from API
     */
    func fetchOnboarding()
    
    func parseResponse(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?)
}

extension OnboardingService {

    func fetchOnboarding() {
        PoqNetworkService(networkTaskDelegate: self).getOnboarding()
    }
    
    func parseResponse(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        if let existedPages = result as? [PoqOnboarding] {
            pages = existedPages
        }
        
        colorPoints = ColorPoint.colorPoints(for: pages)

        presenter?.updatePageControl()
    }
    
    // MARK: PoqNetworkTaskDelegate
    
    func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        presenter?.update(state: .loading, networkTaskType: networkTaskType)
    }

    func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        
        parseResponse(networkTaskType, result: result)
        presenter?.update(state: .completed, networkTaskType: networkTaskType)
    }
    
    func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        
        presenter?.update(state: .error, networkTaskType: networkTaskType, withNetworkError: error)
    }

}
