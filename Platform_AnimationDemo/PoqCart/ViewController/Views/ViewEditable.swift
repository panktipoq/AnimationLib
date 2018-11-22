//
//  EditableView.swift
//  PoqCart
//
//  Created by Balaji Reddy on 14/01/2018.
//

import Foundation

/**
    This protocol represents a view that can be edited.
    Views that conform to this protocol can be notified when the screen enters edit mode.
 */
public protocol ViewEditable {
    func setEditMode(to editing: Bool, animate: Bool)
}
