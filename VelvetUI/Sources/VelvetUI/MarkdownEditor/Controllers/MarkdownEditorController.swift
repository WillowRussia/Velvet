//
//  MarkdownEditorController.swift
//  VelvetUI
//
//  Created by Илья Востров on 18.12.2025.
//

import SwiftUI
import Markdown

// MARK: - MarkdownEditorController
class MarkdownEditorController: @preconcurrency MarkdownEditingController {
    private weak var textView: UITextView?
    private let fontSizeView: CGFloat = 18

    func setTextView(_ textView: UITextView) {
        self.textView = textView
    }

    @MainActor func getCurrentText() -> String {
        guard let textView = self.textView else {
            return ""
        }
        return convertAttributedTextToMarkdown(textView)
    }

    private func isBold(_ attributes: [NSAttributedString.Key: Any]) -> Bool {
        return (attributes[.font] as? UIFont)?.fontDescriptor.symbolicTraits.contains(.traitBold) == true
    }

    private func isItalic(_ attributes: [NSAttributedString.Key: Any]) -> Bool {
        return (attributes[.font] as? UIFont)?.fontDescriptor.symbolicTraits.contains(.traitItalic) == true
    }

    private func isStrikethrough(_ attributes: [NSAttributedString.Key: Any]) -> Bool {
        return (attributes[.strikethroughStyle] as? Int) == NSUnderlineStyle.single.rawValue
    }

    private func isMonospace(_ attributes: [NSAttributedString.Key: Any]) -> Bool {
        return (attributes[.font] as? UIFont)?.fontName.localizedCaseInsensitiveContains("Courier") == true
    }

    private func processSubstringWithAttributes(_ substring: String, attributes: [NSAttributedString.Key: Any]) -> String {
        if isBold(attributes) {
            if let fontSize = attributes[.font] as? UIFont, fontSize.pointSize >= fontSizeView {
                switch Int(fontSize.pointSize - fontSizeView) {
                case 10: return "# \(substring)"
                case 8:  return "## \(substring)"
                case 6:  return "### \(substring)"
                case 4:  return "#### \(substring)"
                case 2:  return "##### \(substring)"
                case 0:  return "###### \(substring)"
                default: break
                }
            }

            if isItalic(attributes) {
                return "***\(substring)***"
            }
            return "**\(substring)**"
        }

        if isItalic(attributes) {
            return "_\(substring)_"
        }

        if let linkURL = attributes[.link] as? URL {
            return "[\(substring)](\(linkURL.absoluteString))"
        }

        if isStrikethrough(attributes) {
            return "~~\(substring)~~"
        }

        if isMonospace(attributes) {
            return "`\(substring)`"
        }

        return substring
    }
}

// MARK: - MarkdownConvertible Implementation
extension MarkdownEditorController: @preconcurrency MarkdownConvertible {
    @MainActor
    func convertAttributedTextToMarkdown(_ textView: UITextView) -> String {
        guard let attributedText = textView.attributedText, attributedText.length > 0 else {
            return ""
        }

        let fullRange = NSRange(location: 0, length: attributedText.length)
        var markdownText = ""

        attributedText.enumerateAttributes(in: fullRange, options: []) { [weak self] (attributes, range, _) in
            let substring = (attributedText.string as NSString).substring(with: range)
            let processedSubstring = self?.processSubstringWithAttributes(substring, attributes: attributes) ?? substring
            markdownText.append(processedSubstring)
        }

        return markdownText
    }
}
