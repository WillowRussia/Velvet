//
//  MarkdownStylingApplier.swift
//  VelvetUI
//
//  Created by Илья Востров on 18.12.2025.
//

import SwiftUI

/// Протокол для объекта, применяющего стили Markdown к атрибутированному тексту.
protocol MarkdownStylingApplier {
    /// Применяет стили Markdown к содержимому TextView.
    /// - Parameter textView: TextView, к которому нужно применить стили.
    func applyMarkdownStyles(to textView: UITextView)
}
