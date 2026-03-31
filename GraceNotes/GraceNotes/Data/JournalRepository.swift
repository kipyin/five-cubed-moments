import Foundation
import SwiftData

struct JournalRepository {
    private let calendar: Calendar

    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    func fetchAllEntries(context: ModelContext) throws -> [JournalEntry] {
        let trace = PerformanceTrace.begin("JournalRepository.fetchAllEntries")
        let descriptor = FetchDescriptor<JournalEntry>(
            sortBy: [SortDescriptor(\.entryDate, order: .reverse)]
        )
        do {
            let entries = try context.fetch(descriptor)
            PerformanceTrace.end("JournalRepository.fetchAllEntries", startedAt: trace)
            return entries
        } catch {
            PerformanceTrace.end("JournalRepository.fetchAllEntries.failed", startedAt: trace)
            throw error
        }
    }

    func fetchEntry(for date: Date, context: ModelContext) throws -> JournalEntry? {
        let dayStart = calendar.startOfDay(for: date)
        return try fetchEntry(dayStart: dayStart, context: context)
    }

    /// True when the user has reached Full/Harvest at least once.
    /// Prefers `completedAt` (cheap query), then scans for legacy rows without that field.
    func hasUserReachedFullHarvest(context: ModelContext) throws -> Bool {
        var completedDescriptor = FetchDescriptor<JournalEntry>(
            predicate: #Predicate<JournalEntry> { entry in
                entry.completedAt != nil
            }
        )
        completedDescriptor.fetchLimit = 1
        if try context.fetch(completedDescriptor).first != nil {
            return true
        }
        let entries = try fetchAllEntries(context: context)
        return entries.contains { $0.completionLevel == .full }
    }

    /// Fetches the journal row for `[dayStart, nextDay)` using the same interval semantics as import and demo seeding.
    func fetchEntry(dayStart: Date, context: ModelContext) throws -> JournalEntry? {
        let trace = PerformanceTrace.begin("JournalRepository.fetchEntry")
        guard let nextDay = calendar.date(byAdding: .day, value: 1, to: dayStart) else {
            PerformanceTrace.end("JournalRepository.fetchEntry.invalidDate", startedAt: trace)
            return nil
        }
        do {
            let descriptor = FetchDescriptor<JournalEntry>(
                predicate: #Predicate { entry in
                    entry.entryDate >= dayStart && entry.entryDate < nextDay
                },
                sortBy: [SortDescriptor(\.entryDate, order: .reverse)]
            )
            let entry = try context.fetch(descriptor).first
            PerformanceTrace.end("JournalRepository.fetchEntry", startedAt: trace)
            return entry
        } catch {
            PerformanceTrace.end("JournalRepository.fetchEntry.failed", startedAt: trace)
            throw error
        }
    }

    /// Returns structured lines and notes whose text contains `query`
    /// (case- and diacritic-insensitive), newest days first. Caps total rows for responsiveness on large stores.
    func searchMatches(
        query: String,
        context: ModelContext,
        maxRows: Int = 200
    ) throws -> [JournalSearchMatch] {
        let trace = PerformanceTrace.begin("JournalRepository.searchMatches")
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            PerformanceTrace.end("JournalRepository.searchMatches.emptyQuery", startedAt: trace)
            return []
        }

        let entries = try fetchAllEntries(context: context)
        var matches: [JournalSearchMatch] = []

        for entry in entries {
            guard matches.count < maxRows else { break }

            let dayStart = calendar.startOfDay(for: entry.entryDate)

            func appendIfMatch(source: ReviewThemeSourceCategory, text: String) {
                guard matches.count < maxRows else { return }
                guard Self.textContains(trimmed, in: text) else { return }
                matches.append(JournalSearchMatch(entryDate: dayStart, source: source, content: text))
            }

            for item in entry.gratitudes ?? [] {
                appendIfMatch(source: .gratitudes, text: item.displayLabel)
            }
            for item in entry.needs ?? [] {
                appendIfMatch(source: .needs, text: item.displayLabel)
            }
            for item in entry.people ?? [] {
                appendIfMatch(source: .people, text: item.displayLabel)
            }

            let notes = entry.readingNotes
            if !notes.isEmpty {
                appendIfMatch(source: .readingNotes, text: notes)
            }

            let reflections = entry.reflections
            if !reflections.isEmpty {
                appendIfMatch(source: .reflections, text: reflections)
            }
        }

        PerformanceTrace.end("JournalRepository.searchMatches", startedAt: trace)
        return matches
    }

    private static func textContains(_ needle: String, in haystack: String) -> Bool {
        haystack.range(
            of: needle,
            options: [.caseInsensitive, .diacriticInsensitive],
            locale: .current
        ) != nil
    }
}
