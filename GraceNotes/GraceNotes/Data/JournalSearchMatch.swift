import Foundation

/// One searchable line or note row tied to a journal day, for Past search results.
struct JournalSearchMatch: Identifiable, Equatable {
    let id: UUID
    let entryDate: Date
    let source: ReviewThemeSourceCategory
    let content: String

    init(entryDate: Date, source: ReviewThemeSourceCategory, content: String) {
        self.id = UUID()
        self.entryDate = entryDate
        self.source = source
        self.content = content
    }
}
