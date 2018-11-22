//
//  ViewState.swift
//  PoqCart
//
//  Created by Balaji Reddy on 20/06/2018.
//

import Foundation

/**
  An enum representing the different states of a screen
 */
public enum ScreenState {
    case awaitingInteraction
    case loading
    case background
    case navigateTo(route: Route)
}
