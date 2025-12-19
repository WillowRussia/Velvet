//
//  Note.swift
//  VelvetUI
//
//  Created by Илья Востров on 17.12.2025.
//

import Foundation


public enum Priority: String, Codable , @unchecked Sendable {
    case nonPriority = "None"
    case lowPriority = "Low"
    case mediumPriority = "Medium"
    case highPriority = "High"
}


public struct Note: Identifiable, Codable, Equatable, @unchecked Sendable {
    public let id: String
    public var title: String
    public let emoji: String
    public var content: String
    public let priority: Priority
    public var isDone: Bool
    public var isCyclic: Bool
    public var dateStart: Date?
    public var dateEnd: Date?
    
    public init(
        id: String = UUID().uuidString,
        title: String,
        emoji: String = "✍️",
        content: String,
        priority: Priority = .nonPriority,
        isDone: Bool = false,
        isCyclic: Bool = false,
        dateStart: Date? = nil,
        dateEnd: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.emoji = emoji
        self.content = content
        self.priority = priority
        self.isDone = isDone
        self.isCyclic = isCyclic
        self.dateStart = dateStart
        self.dateEnd = dateEnd
    }
    
    func toMarkdown() -> String {
        var markdownContent = "# \(title)\n\n"
        markdownContent += "- **ID**: \(id)\n"
        markdownContent += "- **Emoji**: \(emoji)\n"
        markdownContent += "- **Priority**: \(priority.rawValue)\n"
        markdownContent += "- **Task**: \(isDone ? "Yes" : "No")\n"
        markdownContent += "- **Cyclic**: \(isCyclic ? "Yes" : "No")\n"
        markdownContent += "- **Start Date**: \(dateStart.map { Self.dateFormatter.string(from: $0) } ?? "Not set")\n"
        markdownContent += "- **End Date**: \(dateEnd.map { Self.dateFormatter.string(from: $0) } ?? "Not set")\n"
        markdownContent += "\n\(content)\n"
        return markdownContent
    }

    static func fromMarkdown(_ markdown: String) -> Note? {
        let lines = markdown.components(separatedBy: .newlines)
        
        guard let firstLine = lines.first, firstLine.hasPrefix("# ") else { return nil }
        let title = String(firstLine.dropFirst(2)) // убираем "# "
        
        var id: String?
        var emoji: String = "✍️"
        var priority: Priority = .nonPriority
        var isDone = false
        var isCyclic = false
        var dateStart: Date? = nil
        var dateEnd: Date? = nil
        
        let expectedMetadataLineCount = 8
        let metadataLines = lines.dropFirst(1).prefix(expectedMetadataLineCount)
        
        for line in metadataLines {
            if line.starts(with: "- **ID**: ") {
                id = extractValue(from: line, prefix: "- **ID**: ")
            } else if line.starts(with: "- **Emoji**: ") {
                emoji = extractValue(from: line, prefix: "- **Emoji**: ")
            } else if line.starts(with: "- **Priority**: ") {
                let value = extractValue(from: line, prefix: "- **Priority**: ")
                priority = Priority(rawValue: value) ?? .nonPriority
            } else if line.starts(with: "- **Task**: ") {
                let value = extractValue(from: line, prefix: "- **Task**: ")
                isDone = (value == "Yes")
            } else if line.starts(with: "- **Cyclic**: ") {
                let value = extractValue(from: line, prefix: "- **Cyclic**: ")
                isCyclic = (value == "Yes")
            } else if line.starts(with: "- **Start Date**: ") {
                let dateString = extractValue(from: line, prefix: "- **Start Date**: ")
                dateStart = Self.parseDate(dateString)
            } else if line.starts(with: "- **End Date**: ") {
                let dateString = extractValue(from: line, prefix: "- **End Date**: ")
                dateEnd = Self.parseDate(dateString)
            }
        }
        
        guard let noteID = id else { return nil }
        
        // Контент — всё, что после заголовка и 8 метастрок
        let contentStartIndex = 1 + expectedMetadataLineCount
        let contentLines = contentStartIndex < lines.count ? Array(lines[contentStartIndex...]) : []
        let content = contentLines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
        
        return Note(
            id: noteID,
            title: title,
            emoji: emoji,
            content: content,
            priority: priority,
            isDone: isDone,
            isCyclic: isCyclic,
            dateStart: dateStart,
            dateEnd: dateEnd
        )
    }

    // Вспомогательный метод для извлечения значения после префикса
    private static func extractValue(from line: String, prefix: String) -> String {
        return line
            .dropFirst(prefix.count)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // Кэшированный DateFormatter
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    private func formatDate(_ date: Date) -> String {
        Self.dateFormatter.string(from: date)
    }

    private static func parseDate(_ dateString: String) -> Date? {
        guard dateString != "Not set" else { return nil }
        return Self.dateFormatter.date(from: dateString)
    }
}
