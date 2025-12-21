//
//  UIFont.ext.swift
//  VelvetUI
//
//  Created by Илья Востров on 18.12.2025.
//

import UIKit

// MARK: - UIFont Extension for Bold+Italic
extension UIFont {
    func italic() -> UIFont {
        let descriptor = fontDescriptor.withSymbolicTraits([.traitBold, .traitItalic])
        return UIFont(descriptor: descriptor!, size: pointSize)
    }
}
