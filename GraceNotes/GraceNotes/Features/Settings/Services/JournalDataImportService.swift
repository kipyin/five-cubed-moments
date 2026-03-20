import Foundation
import SwiftData

enum JournalDataImportError: Error, Equatable {
    case invalidGraceNotesExport
    case unsupportedSchemaVersion(Int)
}

/// Summary of a completed import. `processedDayCount` is unique calendar days after deduplication.
struct JournalDataImportSummary: Equatable {
    let processedDayCount: Int
    let insertedCount: Int
    let updatedCount: Int
}

/// Item counts per section after import sanitization (for tests).
struct JournalDataImportSanitizedLengths: Equatable {
    let gratitudes: Int
    let needs: Int
    let people: Int
}

struct JournalDataImportService {
    private let maxStringFieldLength = 50_000

    func importData(
        _ data: Data,
        context: ModelContext,
        calendar: Calendar = .current
    ) throws -> JournalDataImportSummary {
        let archive = try decodeArchive(data)
        let entries = dedupeByCalendarDayLastWins(archive.entries, calendar: calendar)

        var inserted = 0
        var updated = 0
        let repository = JournalRepository(calendar: calendar)

        for export in entries {
            let dayStart = calendar.startOfDay(for: export.entryDate)
            let sanitized = sanitize(export)

            if let existing = try repository.fetchEntry(dayStart: dayStart, context: context) {
                // Keep the existing model identity (SwiftData / CloudKit); replace content from the file.
                existing.entryDate = dayStart
                existing.gratitudes = sanitized.gratitudes
                existing.needs = sanitized.needs
                existing.people = sanitized.people
                existing.readingNotes = sanitized.readingNotes
                existing.reflections = sanitized.reflections
                existing.createdAt = sanitized.createdAt
                existing.updatedAt = sanitized.updatedAt
                existing.completedAt = sanitized.completedAt
                updated += 1
            } else {
                context.insert(
                    JournalEntry(
                        id: sanitized.id,
                        entryDate: dayStart,
                        gratitudes: sanitized.gratitudes,
                        needs: sanitized.needs,
                        people: sanitized.people,
                        readingNotes: sanitized.readingNotes,
                        reflections: sanitized.reflections,
                        createdAt: sanitized.createdAt,
                        updatedAt: sanitized.updatedAt,
                        completedAt: sanitized.completedAt
                    )
                )
                inserted += 1
            }
        }

        try context.save()
        return JournalDataImportSummary(
            processedDayCount: entries.count,
            insertedCount: inserted,
            updatedCount: updated
        )
    }

    /// Exposed for unit tests that avoid creating a `ModelContext`.
    /// SwiftData in-memory can crash on some Simulator runtimes.
    internal func decodeArchive(_ data: Data) throws -> JournalDataExportArchive {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let archive: JournalDataExportArchive
        do {
            archive = try decoder.decode(JournalDataExportArchive.self, from: data)
        } catch {
            throw JournalDataImportError.invalidGraceNotesExport
        }
        guard archive.schemaVersion == 1 else {
            throw JournalDataImportError.unsupportedSchemaVersion(archive.schemaVersion)
        }
        return archive
    }

    /// Deduplicate by calendar day: sorted by `entryDate`, last row wins for that day.
    internal func dedupeByCalendarDayLastWins(
        _ entries: [JournalDataExportEntry],
        calendar: Calendar
    ) -> [JournalDataExportEntry] {
        let sorted = entries.sorted { $0.entryDate < $1.entryDate }
        var byDayStart: [Date: JournalDataExportEntry] = [:]
        for entry in sorted {
            let day = calendar.startOfDay(for: entry.entryDate)
            byDayStart[day] = entry
        }
        return byDayStart.keys.sorted().compactMap { byDayStart[$0] }
    }

    /// For unit tests without a live SwiftData stack.
    internal func sanitizedSectionLengths(for export: JournalDataExportEntry) -> JournalDataImportSanitizedLengths {
        let sanitized = sanitize(export)
        return JournalDataImportSanitizedLengths(
            gratitudes: sanitized.gratitudes.count,
            needs: sanitized.needs.count,
            people: sanitized.people.count
        )
    }

    private func sanitize(_ export: JournalDataExportEntry) -> SanitizedExport {
        let gratitudes = mapItems(Array(export.gratitudes.prefix(JournalEntry.slotCount)))
        let needs = mapItems(Array(export.needs.prefix(JournalEntry.slotCount)))
        let people = mapItems(Array(export.people.prefix(JournalEntry.slotCount)))
        return SanitizedExport(
            id: export.id,
            gratitudes: gratitudes,
            needs: needs,
            people: people,
            readingNotes: clampString(export.readingNotes),
            reflections: clampString(export.reflections),
            createdAt: export.createdAt,
            updatedAt: export.updatedAt,
            completedAt: export.completedAt
        )
    }

    private func mapItems(_ items: [JournalDataExportItem]) -> [JournalItem] {
        items.map { item in
            JournalItem(
                fullText: clampString(item.fullText),
                chipLabel: item.chipLabel.map { clampString($0) },
                isTruncated: item.isTruncated,
                id: item.id
            )
        }
    }

    private func clampString(_ value: String) -> String {
        guard value.count > maxStringFieldLength else { return value }
        return String(value.prefix(maxStringFieldLength))
    }

    private struct SanitizedExport {
        let id: UUID
        let gratitudes: [JournalItem]
        let needs: [JournalItem]
        let people: [JournalItem]
        let readingNotes: String
        let reflections: String
        let createdAt: Date
        let updatedAt: Date
        let completedAt: Date?
    }
}
