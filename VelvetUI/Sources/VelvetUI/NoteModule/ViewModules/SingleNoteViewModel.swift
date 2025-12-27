//
//  SingleNoteViewModel.swift
//  VelvetUI
//
//  Created by Илья Востров on 22.12.2025.
//


import Foundation
import SwiftUI

@MainActor
public final class SingleNoteViewModel: ObservableObject {
    
    // MARK: - Private Properties
    private let noteService: NoteService
    
    // MARK: - Published Properties
    @Published public var title: String
    @Published public var noteText: String
    @Published public var selectedDate: Date?
    @Published public var showDatePicker: Bool = false
    
    // MARK: - Internal State
    private var note: Note 
    
    // MARK: - Computed Properties
    public var isSaveButtonShown: Bool {
        title != note.title || noteText != note.content || selectedDate != note.dateEnd
    }
    
    // MARK: - Initialization
    init(note: Note, noteService: NoteService) {
        self.note = note
        self.title = note.title
        self.noteText = note.content
        self.selectedDate = note.dateEnd
        self.noteService = noteService
    }
    
    // MARK: - Public API
    /// Сохраняет изменения заметки через сервис.
    public func saveNote(_ noteTextMD: String) async throws {
            let localNoteTextMD = noteTextMD
            
            try await noteService.saveNote(
                id: self.note.id,
                title: self.title,
                content: localNoteTextMD,
                dateEnd: self.selectedDate
            )
            
            self.note.title = self.title
            self.note.content = localNoteTextMD
            self.note.dateEnd = self.selectedDate
        }
}
