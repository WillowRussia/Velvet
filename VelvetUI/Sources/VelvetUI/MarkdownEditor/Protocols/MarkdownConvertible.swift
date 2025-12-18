//
//  MarkdownConvertible.swift
//  VelvetUI
//
//  Created by Илья Востров on 18.12.2025.
//

import SwiftUI

/// Протокол для объекта, способного конвертировать атрибутированный текст в Markdown.
protocol MarkdownConvertible {
    /// Преобразует содержимое заданного UITextView в строку формата Markdown.
    /// - Parameter textView: TextView, содержимое которого нужно преобразовать.
    /// - Returns: Строка в формате Markdown.
    func convertAttributedTextToMarkdown(_ textView: UITextView) -> String
}

/// Протокол для объекта, управляющего Markdown-редактором.
protocol MarkdownEditingController: ObservableObject {
    /// Устанавливает TextView, с которым будет работать контроллер.
    /// - Parameter textView: TextView для управления.
    func setTextView(_ textView: UITextView)
    
    /// Возвращает текущий текст в формате Markdown.
    /// - Returns: Текущий текст редактора в формате Markdown.
    func getCurrentText() -> String
}
