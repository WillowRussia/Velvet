//
//  NoteCellView.swift
//  VelvetUI
//
//  Created by Илья Востров on 22.12.2025.
//


import SwiftUI

struct NoteCellView: View {
    
    let note: Note
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            noteTitleWithEmoji
            noteBody
        }
        .padding(.horizontal, 30)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 25)
        .background(.gray.opacity(0.1))
        .clipShape(.rect(cornerRadius: 12))
        .shadow(color: .black.opacity(0.3), radius: 10)
    }
    
    private var noteTitleWithEmoji: some View {
        HStack {
            Text(note.emoji)
                .font(.headline)
            Text(note.title)
                .font(.headline)
                .foregroundStyle(.primary)
                .lineLimit(1)
                .truncationMode(.tail)
        }
    }
    
    private var noteBody: some View {
        Text(note.content)
            .font(.footnote)
            .foregroundStyle(.primary)
            .lineLimit(3)
            .truncationMode(.tail)
    }
}
