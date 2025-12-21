//
//  DataBaseFacadeProtocol.swift
//  VelvetUI
//
//  Created by Илья Востров on 18.12.2025.
//


import Foundation

@MainActor
public protocol DataBaseProtocol {
    func saveNote(note: NoteCD) async throws
    func fetchNotes() throws -> [NoteCD]
    func deleteNote(fileUrl: URL) async throws
}
