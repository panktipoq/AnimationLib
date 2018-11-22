//
//  OnboardingViewModel.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Nikolay Dzhulay on 12/15/16.
//
//

import Foundation
import PoqNetworking

class OnboardingViewModel: OnboardingService {
    
    // MARK: OnboardingDataProvider
    weak var presenter: PoqOnboardingPresenter?
    
    var pages = [PoqOnboarding]()
    
    var colorPoints = [ColorPoint]()
}
