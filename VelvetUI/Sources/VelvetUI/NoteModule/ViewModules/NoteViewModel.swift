//
//  NoteViewModel.swift
//  VelvetUI
//
//  Created by Илья Востров on 19.12.2025.
//

import Foundation
import SwiftUI

@MainActor
final class NoteViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published public var notes: [Note] = []
    @Published public var completedNotes: [Note] = []
    @Published public var selectedNote: Note?
    
    // MARK: - Private Properties
    public let noteService: NoteService
    
    // MARK: - Initialization
    init(noteService: NoteService) async {
        self.noteService = noteService
        await loadNotes()
    }
    
    // MARK: - Public API
    /// Загружает все заметки из сервиса и разделяет их на активные и завершённые.
    public func loadNotes() async {
            do {
                let loadedNotes = try await noteService.fetchNotes() 
                self.notes = loadedNotes.filter { !$0.isDone }
                self.completedNotes = loadedNotes.filter { $0.isDone }
            } catch {
                print("Ошибка загрузки заметок: \(error.localizedDescription)")
            }
    }
    
    /// Сохраняет заметку через сервис и обновляет состояние ViewModel.
    public func saveNote(_ note: Note) async {
        do {
            try await noteService.saveNote(note: note)
            
            if note.isDone {
                self.notes.removeAll { $0.id == note.id }
                self.completedNotes.removeAll { $0.id == note.id }
                self.completedNotes.append(note)
            } else {
                self.completedNotes.removeAll { $0.id == note.id }
                self.notes.removeAll { $0.id == note.id }
                self.notes.append(note)
            }
        } catch {
            print("Ошибка сохранения заметки: \(error.localizedDescription)")
        }
    }
    
    /// Удаляет заметку через сервис и удаляет её из ViewModel.
    public func deleteNote(_ note: Note) async {
            do {
                try await noteService.deleteNote(note: note)
                    self.notes.removeAll { $0.id == note.id }
                    self.completedNotes.removeAll { $0.id == note.id }
            } catch {
                print("Ошибка удаления заметки: \(error.localizedDescription)")
            }
    }
    
    /// Переключает статус задачи (сделано/не сделано).
    public func toggleTask(for note: Note) async {
        var updatedNote = note
        updatedNote.isDone.toggle()
        await saveNote(updatedNote)
    }
}
