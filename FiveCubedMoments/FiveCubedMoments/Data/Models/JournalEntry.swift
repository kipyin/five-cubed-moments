import Foundation
import SwiftData

@Model
final class JournalEntry {
    var id: UUID
    var entryDate: Date
    var gratitudes: [JournalItem]
    var needs: [JournalItem]
    var people: [JournalItem]
    var bibleNotes: String
    var reflections: String
    var createdAt: Date
    var updatedAt: Date
    var completedAt: Date?

    init(
        id: UUID = UUID(),
        entryDate: Date = .now,
        gratitudes: [JournalItem] = [],
        needs: [JournalItem] = [],
        people: [JournalItem] = [],
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

    /// Whether this entry meets completion criteria. Matches ViewModel logic so History and Journal detail are consistent.
    var isComplete: Bool {
        let notesTrimmed = bibleNotes.trimmingCharacters(in: .whitespacesAndNewlines)
        let reflectionsTrimmed = reflections.trimmingCharacters(in: .whitespacesAndNewlines)
        return gratitudes.count >= Self.slotCount &&
            needs.count >= Self.slotCount &&
            people.count >= Self.slotCount &&
            !notesTrimmed.isEmpty &&
            !reflectionsTrimmed.isEmpty
    }

    static let slotCount = 5
}
