//
//  SheetActionButton.swift
//  PoqPlatform
//
//  Created by Nikolay Dzhulay on 9/22/17.
//

import Foundation

public final class SheetActionButton: UIButton {

    var action: SheetContainerViewController.ActionButton? {
        didSet {
            setTitle(action?.text, for: .normal)
        }
    }

    public init(frame: CGRect, cornerRadius: CGFloat) {
        super.init(frame: frame)

        let backgroundImage = UIImage.createResizableColoredImage(UIColor.white, cornerRadius: cornerRadius)
        setBackgroundImage(backgroundImage, for: .normal)
        translatesAutoresizingMaskIntoConstraints = false

        let titleColor = UIColor(red: 0, green: 125.0/255.0, blue: 237.0/255.0, alpha: 1.0)
        setTitleColor(titleColor, for: .normal)

        addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public static let SheetActionButtonHeight: CGFloat = 60
    public override var intrinsicContentSize: CGSize {
        let buttonWidth: CGFloat
        if let superviewWidth = superview?.bounds.size.width {
            buttonWidth = superviewWidth - 2 * SheetScreenEdgeIndent
        } else {
            buttonWidth = 0
        }

        return CGSize(width: buttonWidth, height: SheetActionButton.SheetActionButtonHeight)
    }

    // MARK: Private
    @objc func buttonAction(_ sender: SheetActionButton) {
        action?.action()
    }
}
