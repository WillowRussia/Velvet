//
//  NoteServiceError.swift
//  VelvetUI
//
//  Created by Илья Востров on 18.12.2025.
//

import Foundation

enum NoteServiceError: LocalizedError {
    case invalidFileURL(String)
    case failedToReadFile(String)
    case failedToDeleteFile(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidFileURL(let path):
            return "Invalid file URL: \(path)"
        case .failedToReadFile(let path):
            return "Failed to read file at: \(path)"
        case .failedToDeleteFile(let path):
            return "Failed to delete file at: \(path)"
        }
    }
}
