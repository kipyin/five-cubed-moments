import Foundation
import SwiftData

struct JournalRepository {
    private let calendar: Calendar

    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    func fetchAllEntries(context: ModelContext) throws -> [JournalEntry] {
        let descriptor = FetchDescriptor<JournalEntry>(
            sortBy: [SortDescriptor(\.entryDate, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    func fetchEntry(for date: Date, context: ModelContext) throws -> JournalEntry? {
        let dayStart = calendar.startOfDay(for: date)
        guard let nextDay = calendar.date(byAdding: .day, value: 1, to: dayStart) else {
            return nil
        }
        let descriptor = FetchDescriptor<JournalEntry>(
            predicate: #Predicate { entry in
                entry.entryDate >= dayStart && entry.entryDate < nextDay
            },
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        return try context.fetch(descriptor).first
    }
}
