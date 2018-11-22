//
//  PoqFilterProductListExtension.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Nikolay Dzhulay on 2/20/17.
//
//

import Foundation
import PoqNetworking

extension PoqFilter {

    /// Return true if any of filters applied. Keyword is not counted as filter here
    public var isFiltersApplied: Bool {
    
        if let selectedCategoriesCount = selectedCategories?.count, selectedCategoriesCount > 0 {
            return true
        }

        if let selectedSizesCount = selectedSizes?.count, selectedSizesCount > 0 {
            return true
        }
        
        if let selectedSizeValuesCount = selectedSizeValues?.count, selectedSizeValuesCount > 0 {
            return true
        }
        
        if let selectedColorsCount = selectedColors?.count, selectedColorsCount > 0 {
            return true
        }
        
        if let selectedColorValuesCount = selectedColorValues?.count, selectedColorValuesCount > 0 {
            return true
        }
        
        if let selectedBrandsCount = selectedBrands?.count, selectedBrandsCount > 0 {
            return true
        }
        
        if let selectedStylesCount = selectedStyles?.count, selectedStylesCount > 0 {
            return true
        }
        
        if let selectedRatingsCount = selectedRatings?.count, selectedRatingsCount > 0 {
            return true
        }
        
        if let _ = selectedMinPrice {
            return true
        }
        
        if let _ = selectedMaxPrice {
            return true
        }

        if let selectedRefinementsCount = selectedRefinements?.count, selectedRefinementsCount > 0 {
            return true
        }
        
        return false
    }

}
