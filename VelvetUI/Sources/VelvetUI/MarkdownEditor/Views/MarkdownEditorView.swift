//
//  MarkdownEditorView.swift
//  VelvetUI
//
//  Created by Илья Востров on 18.12.2025.
//

import SwiftUI

// MARK: - MarkdownEditor View
struct MarkdownEditor: UIViewRepresentable {
    @Binding var text: String
    var controller: any MarkdownEditingController

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.backgroundColor = UIColor.systemBackground
        textView.isScrollEnabled = true
        textView.dataDetectorTypes = [.link]
        textView.autocorrectionType = .yes
        textView.spellCheckingType = .yes
        textView.text = text
        controller.setTextView(textView)
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        let oldSelectedRange = uiView.selectedRange
        let oldTextLength = uiView.text.count

        context.coordinator.applyMarkdownStyles(to: uiView)

        let newTextLength = uiView.text.count
        let deltaLength = oldTextLength - newTextLength

        let correctedLocation = max(0, min(oldSelectedRange.location - deltaLength, uiView.text.count))
        let correctedRange = NSRange(location: correctedLocation, length: 0)
        DispatchQueue.main.async {
            uiView.selectedRange = correctedRange
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}
