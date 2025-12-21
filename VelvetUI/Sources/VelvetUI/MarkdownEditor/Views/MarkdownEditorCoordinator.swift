//
//  MarkdownEditorCoordinator.swift
//  VelvetUI
//
//  Created by Илья Востров on 18.12.2025.
//

import SwiftUI
import Markdown

// MARK: - Coordinator
extension MarkdownEditor {
    final class Coordinator: NSObject, UITextViewDelegate, @preconcurrency MarkdownStylingApplier {
        var parent: MarkdownEditor
        private let fontSizeView: CGFloat = 18

        init(_ parent: MarkdownEditor) {
            self.parent = parent
        }

        func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
            UIApplication.shared.open(URL, options: [:], completionHandler: nil)
            return false
        }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if text == "\n" {
                handleNewLine(textView, range: range)
                return false
            } else if text == " " {
                insertPlainSpace(textView, range: range)
                return false
            }
            return true
        }

        private func handleNewLine(_ textView: UITextView, range: NSRange) {
            let currentText = textView.text ?? ""
            let lineRange = (currentText as NSString).lineRange(for: NSRange(location: range.location, length: 0))
            let previousLine = (currentText as NSString).substring(with: lineRange).trimmingCharacters(in: .whitespaces)

            var newText = "\n"
            var cursorOffset = 1

            if previousLine.starts(with: "- ") {
                newText += "- "
                cursorOffset = 3
            } else if let match = findListItemNumber(previousLine) {
                let number = Int(exactly: match)! + 1
                newText += "\(number). "
                cursorOffset = "\(number). ".count
            }

            textView.textStorage.replaceCharacters(in: range, with: newText)
            let newCursorPosition = range.location + cursorOffset
            textView.selectedRange = NSRange(location: newCursorPosition, length: 0)

            DispatchQueue.main.async {
                self.applyMarkdownStyles(to: textView)
            }
        }

        private func insertPlainSpace(_ textView: UITextView, range: NSRange) {
            let plainSpace = NSAttributedString(string: " ", attributes: [
                .font: UIFont.systemFont(ofSize: fontSizeView),
                .foregroundColor: UIColor.label
            ])
            let mutableAttributedString = NSMutableAttributedString(attributedString: textView.attributedText!)
            mutableAttributedString.replaceCharacters(in: range, with: plainSpace)
            textView.attributedText = mutableAttributedString

            let cursorPosition = NSRange(location: range.location + 1, length: 0)
            textView.selectedRange = cursorPosition
            parent.text = textView.attributedText.string
        }

        private func findListItemNumber(_ line: String) -> Int? {
            let regexPattern = #"^(\d+)\.\s"#
            guard let regex = try? NSRegularExpression(pattern: regexPattern),
                  let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
                  let range = Range(match.range(at: 1), in: line) else { return nil }
            return Int(line[range])
        }

        // MARK: - Markdown Styling Logic (from MarkdownStylingApplier protocol)
        func applyMarkdownStyles(to textView: UITextView) {
            guard let rawText = textView.text else { return }
            let document = Document(parsing: rawText)
            let mutableAttributedString = NSMutableAttributedString(
                string: rawText,
                attributes: [.font: UIFont.systemFont(ofSize: fontSizeView)]
            )

            processBlockElements(document.children, in: mutableAttributedString)
            textView.attributedText = mutableAttributedString
        }

        private func processBlockElements(_ elements: MarkupChildren, in attributedText: NSMutableAttributedString) {
            for element in elements {
                switch element {
                case let heading as Heading:
                    applyHeadingStyle(heading, in: attributedText)
                case let paragraph as Paragraph:
                    processInlineElements(paragraph.inlineChildren, in: attributedText)
                case let list as UnorderedList:
                    processListItems(list.children, in: attributedText)
                case let list as OrderedList:
                    processListItems(list.children, in: attributedText)
                default:
                    continue
                }
            }
        }

        private func processListItems(_ items: MarkupChildren, in attributedText: NSMutableAttributedString) {
            for item in items {
                if let listItem = item as? ListItem {
                    processBlockElements(listItem.children, in: attributedText)
                }
            }
        }

        private func processInlineElements(_ elements: LazyMapSequence<MarkupChildren, InlineMarkup>, in attributedText: NSMutableAttributedString) {
            for element in elements {
                switch element {
                case let strong as Strong:
                    applyBoldFormatting(to: strong.plainText, in: attributedText)
                case let emphasis as Emphasis:
                    processEmphasisElement(emphasis, in: attributedText)
                case let link as Markdown.Link:
                    applyLinkFormatting(link, in: attributedText)
                case let code as InlineCode:
                    applyInlineCodeFormatting(code, in: attributedText)
                case let strikethrough as Strikethrough:
                    applyStrikethroughFormatting(strikethrough, in: attributedText)
                default:
                    continue
                }
            }
        }

        private func processEmphasisElement(_ emphasis: Emphasis, in attributedText: NSMutableAttributedString) {
            for childElement in emphasis.inlineChildren {
                if let strong = childElement as? Strong {
                    applyBoldItalicFormatting(to: strong.plainText, in: attributedText)
                } else {
                    applyItalicFormatting(to: emphasis.plainText, in: attributedText)
                }
            }
        }

        // MARK: - Style Application Methods
        private func applyHeadingStyle(_ heading: Heading, in attributedText: NSMutableAttributedString) {
            let rawText = heading.plainText
            let markdownPrefix = String(repeating: "#", count: heading.level) + " "
            let searchPattern = markdownPrefix + rawText

            if let range = findRange(of: searchPattern, in: attributedText) {
                let cleanRange = NSRange(location: range.location + markdownPrefix.count, length: rawText.count)
                attributedText.replaceCharacters(in: range, with: rawText)

                let fontSize = max(fontSizeView, CGFloat(fontSizeView * 2 - CGFloat(heading.level * 2)))
                let boldFont = UIFont.boldSystemFont(ofSize: fontSize)

                attributedText.addAttribute(.font, value: boldFont, range: cleanRange)
            }
        }

        private func applyBoldFormatting(to text: String, in attributedText: NSMutableAttributedString) {
            for pattern in ["**\(text)**", "__\(text)__"] {
                if let range = findRange(of: pattern, in: attributedText) {
                    attributedText.replaceCharacters(in: range, with: text)
                    let newRange = NSRange(location: range.location, length: text.count)
                    attributedText.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: fontSizeView), range: newRange)
                    break
                }
            }
        }

        private func applyItalicFormatting(to text: String, in attributedText: NSMutableAttributedString) {
            for pattern in ["_\(text)_", "*\(text)*"] {
                if let range = findRange(of: pattern, in: attributedText) {
                    attributedText.replaceCharacters(in: range, with: text)
                    let newRange = NSRange(location: range.location, length: text.count)
                    attributedText.addAttribute(.font, value: UIFont.italicSystemFont(ofSize: fontSizeView), range: newRange)
                    break
                }
            }
        }

        private func applyBoldItalicFormatting(to text: String, in attributedText: NSMutableAttributedString) {
            for pattern in ["***\(text)***", "___\(text)___"] {
                if let range = findRange(of: pattern, in: attributedText) {
                    attributedText.replaceCharacters(in: range, with: text)
                    let newRange = NSRange(location: range.location, length: text.count)
                    let boldItalicFont = UIFont.boldSystemFont(ofSize: fontSizeView).italic()
                    attributedText.addAttribute(.font, value: boldItalicFont, range: newRange)
                    break
                }
            }
        }

        private func applyInlineCodeFormatting(_ code: InlineCode, in attributedText: NSMutableAttributedString) {
            let rawText = code.plainText
            let searchPattern = "`\(rawText)`"

            if let range = findRange(of: searchPattern, in: attributedText) {
                attributedText.replaceCharacters(in: range, with: rawText)
                let newRange = NSRange(location: range.location, length: rawText.count)

                let monospaceFont = UIFont(name: "Courier", size: fontSizeView) ?? UIFont.systemFont(ofSize: fontSizeView)
                attributedText.addAttributes([
                    .font: monospaceFont,
                    .foregroundColor: UIColor.systemBlue
                ], range: newRange)
            }
        }

        private func applyStrikethroughFormatting(_ strikethrough: Strikethrough, in attributedText: NSMutableAttributedString) {
            let rawText = strikethrough.plainText
            let searchPattern = "~~\(rawText)~~"

            if let range = findRange(of: searchPattern, in: attributedText) {
                attributedText.replaceCharacters(in: range, with: rawText)
                let newRange = NSRange(location: range.location, length: rawText.count)
                attributedText.addAttributes([
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    .font: UIFont.systemFont(ofSize: fontSizeView)
                ], range: newRange)
            }
        }

        private func applyLinkFormatting(_ link: Markdown.Link, in attributedText: NSMutableAttributedString) {
            let rawText = link.plainText
            let destination = link.destination ?? ""
            let searchPattern = "[\(rawText)](\(destination))"

            if let range = findRange(of: searchPattern, in: attributedText) {
                attributedText.replaceCharacters(in: range, with: rawText)
                let newRange = NSRange(location: range.location, length: rawText.count)

                let linkURL = URL(string: destination) ?? URL(fileURLWithPath: "/")
                attributedText.addAttributes([
                    .link: linkURL,
                    .font: UIFont.systemFont(ofSize: fontSizeView),
                    .foregroundColor: UIColor.systemBlue
                ], range: newRange)
            }
        }

        private func findRange(of substring: String, in attributedText: NSMutableAttributedString) -> NSRange? {
            let range = NSRange(location: 0, length: attributedText.length)
            let foundRange = attributedText.string.range(of: substring, options: [], range: Range(range, in: attributedText.string))
            return foundRange.map { NSRange($0, in: attributedText.string) }
        }
    }
}
