import Foundation
import SwiftData

@Model
final class JournalEntry {
    var id: UUID
    var entryDate: Date
    var gratitudes: [String]
    var needs: [String]
    var people: [String]
    var bibleNotes: String
    var reflections: String
    var createdAt: Date
    var updatedAt: Date
    var completedAt: Date?

    init(
        id: UUID = UUID(),
        entryDate: Date = .now,
        gratitudes: [String] = [],
        needs: [String] = [],
        people: [String] = [],
        bibleNotes: String = "",
        reflections: String = "",
        createdAt: Date = .now,
        updatedAt: Date = .now,
        completedAt: Date? = nil
    ) {
        self.id = id
        self.entryDate = Calendar.current.startOfDay(for: entryDate)
        self.gratitudes = gratitudes
        self.needs = needs
        self.people = people
        self.bibleNotes = bibleNotes
        self.reflections = reflections
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.completedAt = completedAt
    }
}
