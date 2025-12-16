// The Swift Programming Language
// https://docs.swift.org/swift-book
//
//  Note.swift
//  ToDoListApp
//
//  Created by Soslan Dzampaev on 14.11.2024.
//

import Foundation

public enum Priority: String, Codable, Sendable {
    case nonPriority = "None"
    case lowPriority = "Low"
    case mediumPriority = "Medium"
    case highPriority = "High"
}

public struct Note: Identifiable, Sendable {
    public let id: String
    public var title: String
    public let emoji: String
    public var content: String
    public let priority: Priority
    public var isDone: Bool
    public var isCyclically: Bool
    public var dateStart: Date?
    public var dateEnd: Date?
    
    public init(
        id: String = UUID().uuidString,
        title: String,
        emoji: String = "✍️",
        content: String,
        priority: Priority = .nonPriority,
        isDone: Bool = false,
        isCyclically: Bool = false,
        dateStart: Date? = nil,
        dateEnd: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.emoji = emoji
        self.content = content
        self.priority = priority
        self.isDone = isDone
        self.isCyclically = isCyclically
        self.dateStart = dateStart
        self.dateEnd = dateEnd
    }
    
    func toMarkdown() -> String {
        var markdownContent = "# \(title)\n\n"
        markdownContent += "- **ID**: \(id)\n"
        markdownContent += "- **Emoji**: \(emoji)\n"
        markdownContent += "- **Priority**: \(priority.rawValue)\n"
        markdownContent += "- **Task**: \(isDone ? "Yes" : "No")\n"
        markdownContent += "- **Cyclic**: \(isCyclically ? "Yes" : "No")\n"
        markdownContent += "- **Start Date**: \(dateStart != nil ? formatDate(dateStart!) : "Not set")\n"
        markdownContent += "- **End Date**: \(dateEnd != nil ? formatDate(dateEnd!) : "Not set")\n"
        markdownContent += "\n\(content)\n"
        return markdownContent
    }

    static func fromMarkdown(_ markdown: String) -> Note? {
        let lines = markdown.components(separatedBy: .newlines)
        
        guard let title = lines.first?.replacingOccurrences(of: "# ", with: "") else { return nil }
        
        var id: String = UUID().uuidString
        var emoji: String = "✍️"
        var priority: Priority = .nonPriority
        var isDone = false
        var isCyclically = false
        var dateStart: Date? = nil
        var dateEnd: Date? = nil
        
        for line in lines {
            if line.starts(with: "- **ID**:") {
                id = line.replacingOccurrences(of: "- **ID**: ", with: "").trimmingCharacters(in: .whitespaces)
            } else if line.starts(with: "- **Emoji**:") {
                emoji = line.replacingOccurrences(of: "- **Emoji**: ", with: "").trimmingCharacters(in: .whitespaces)
            } else if line.starts(with: "- **Priority**:") {
                let value = line.replacingOccurrences(of: "- **Priority**: ", with: "").trimmingCharacters(in: .whitespaces)
                priority = Priority(rawValue: value) ?? .nonPriority
            } else if line.starts(with: "- **Task**:") {
                isDone = line.contains("Yes")
            } else if line.starts(with: "- **Cyclic**:") {
                isCyclically = line.contains("Yes")
            } else if line.starts(with: "- **Start Date**:") {
                let dateString = line.replacingOccurrences(of: "- **Start Date**: ", with: "").trimmingCharacters(in: .whitespaces)
                dateStart = parseDate(dateString)
            } else if line.starts(with: "- **End Date**:") {
                let dateString = line.replacingOccurrences(of: "- **End Date**: ", with: "").trimmingCharacters(in: .whitespaces)
                dateEnd = parseDate(dateString)
            }
        }
        
        let content = lines.dropFirst(9).joined(separator: "\n")
        
        return Note(
            id: id,
            title: title,
            emoji: emoji,
            content: content,
            priority: priority,
            isDone: isDone,
            isCyclically: isCyclically,
            dateStart: dateStart,
            dateEnd: dateEnd
        )
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    private static func parseDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.date(from: dateString)
    }
    
    
    static let MOCK_LIST: [Note] = [
        .init(
            title: "Написать отчёт по ревью",
            emoji: "🛩️",
            content: "Nearly all Markdown applications support the basic syntax outlined in the original Markdown design document. There are minor variations and discrepancies between Markdown processors — those are noted inline wherever possible."
        ),
        .init(
            title: "Ревью макетов",
            emoji: "🔥",
            content: "Nearly all Markdown applications support the basic syntax outlined in the original Markdown design document. There are minor variations and discrepancies between Markdown processors — those are noted inline wherever possible."
        ),
        .init(
            title: "Написать отзывы ребятам",
            emoji: "🎾",
            content: "Nearly all Markdown applications support the basic syntax outlined in the original Markdown design document. There are minor variations and discrepancies between Markdown processors — those are noted inline wherever possible."
        ),
        .init(
            title: "Составить план для концепта",
            emoji: "😃",
            content: "Nearly all Markdown applications support the basic syntax outlined in the original Markdown design document. There are minor variations and discrepancies between Markdown processors — those are noted inline wherever possible.",
            dateEnd: Calendar.current.date(byAdding: .day, value: 2, to: Date())
        ),

    ]
    
}


