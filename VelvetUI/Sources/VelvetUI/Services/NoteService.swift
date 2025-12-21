//
//  NoteService.swift
//  VelvetUI
//
//  Created by Илья Востров on 18.12.2025.
//

import Foundation

@MainActor
final class NoteService {
    private let fileManager: FileManager
    private let documentsDirectory: URL
    private let database: DataBaseProtocol
    
    init(
        database: DataBaseProtocol,
        fileManager: FileManager = .default,
        documentsDirectory: URL? = nil
    ) {
        self.database = database
        self.fileManager = fileManager
        self.documentsDirectory = documentsDirectory ?? fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    // MARK: - Private Helper
    private func urlForNote(withId id: String) -> URL {
        return documentsDirectory.appendingPathComponent("\(id).md")
    }
    
    // MARK: - Public API
    /// Сохраняет заметку в файл и добавляет ссылку в базу данных.
    func saveNote(note: Note) async throws {
        let fileURL = urlForNote(withId: note.id)
        let markdownContent = note.toMarkdown()
        
        do {
            try markdownContent.write(to: fileURL, atomically: true, encoding: .utf8)
            print("Файл заметки сохранён: \(fileURL.path)")
        } catch {
            let nsError = error as NSError
            print("Ошибка сохранения файла: \(nsError.localizedDescription)")
            throw nsError
        }
        
        let noteCD = NoteCD(fileUrl: fileURL)
        print("note CD \(noteCD)")
        do {
            try await database.saveNote(note: noteCD)
            print("Ссылка на заметку сохранена в базу данных.")
        } catch {
            print("Ошибка сохранения ссылки в базу данных: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Загружает все заметки из базы данных и читает их содержимое из файлов.
    func fetchNotes() async throws -> [Note] {
        let noteCDs = try database.fetchNotes()
        var notes: [Note] = []
        var seenIds: Set<String> = []
        
        for noteCD in noteCDs {
            let fileURL = noteCD.fileUrl
            
            guard fileManager.fileExists(atPath: fileURL.path) else {
                print("Файл не найден, пропускаем: \(fileURL.path)")
                continue
            }
            
            do {
                let content = try String(contentsOf: fileURL, encoding: .utf8)
                
                if let note = Note.fromMarkdown(content),
                   !seenIds.contains(note.id) {
                    notes.append(note)
                    seenIds.insert(note.id)
                }
            } catch {
                print("Ошибка чтения файла \(fileURL.path): \(error.localizedDescription)")
                throw NoteServiceError.failedToReadFile(fileURL.path)
            }
        }
        return notes
    }
    
    /// Удаляет файл заметки и удаляет ссылку из базы данных.
    func deleteNote(note: Note) async throws {
        let fileURL = urlForNote(withId: note.id)
        
        if fileManager.fileExists(atPath: fileURL.path) {
            do {
                try fileManager.removeItem(at: fileURL)
                print("Файл заметки удалён: \(fileURL.path)")
            } catch {
                let nsError = error as NSError
                print("Ошибка удаления файла: \(nsError.localizedDescription)")
                throw NoteServiceError.failedToDeleteFile(fileURL.path)
            }
        } else {
            print("Файл заметки не найден, пропускаем удаление: \(fileURL.path)")
        }
        
        do {
            try await database.deleteNote(fileUrl: fileURL)
            print("Ссылка на заметку удалена из базы данных.")
        } catch {
            print("Ошибка удаления ссылки из базы данных: \(error.localizedDescription)")
            throw error
        }
    }
}
