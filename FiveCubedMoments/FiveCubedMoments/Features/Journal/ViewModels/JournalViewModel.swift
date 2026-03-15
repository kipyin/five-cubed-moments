import Foundation
import Combine
import SwiftData

struct JournalExportPayload {
    let dateFormatted: String
    let gratitudes: [String]
    let needs: [String]
    let people: [String]
    let bibleNotes: String
    let reflections: String
}

@MainActor
final class JournalViewModel: ObservableObject {
    @Published var entryDate: Date = .now
    @Published var gratitudes: [String] = JournalViewModel.emptySlots
    @Published var needs: [String] = JournalViewModel.emptySlots
    @Published var people: [String] = JournalViewModel.emptySlots
    @Published var bibleNotes: String = ""
    @Published var reflections: String = ""
    @Published private(set) var saveErrorMessage: String?

    private static let slotCount = 5
    private static let emptySlots = Array(repeating: "", count: slotCount)

    private let calendar: Calendar
    private let nowProvider: () -> Date
    private let repository: JournalRepository
    private let autosaveTrigger = PassthroughSubject<Void, Never>()
    private var cancellables: Set<AnyCancellable> = []

    private var modelContext: ModelContext?
    private var journalEntry: JournalEntry?
    private var hasLoadedToday = false
    private var isHydrating = false

    init(
        calendar: Calendar = .current,
        nowProvider: @escaping () -> Date = Date.init,
        repository: JournalRepository? = nil
    ) {
        self.calendar = calendar
        self.nowProvider = nowProvider
        self.repository = repository ?? JournalRepository(calendar: calendar)

        autosaveTrigger
            .debounce(for: .milliseconds(400), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.persistChanges()
            }
            .store(in: &cancellables)
    }

    func loadTodayIfNeeded(using context: ModelContext) {
        guard !hasLoadedToday else { return }
        hasLoadedToday = true
        loadEntry(for: nowProvider(), using: context)
    }

    func loadEntry(for date: Date, using context: ModelContext) {
        modelContext = context
        let dayStart = calendar.startOfDay(for: date)

        do {
            if let existing = try repository.fetchEntry(for: date, context: context) {
                hydrate(from: existing)
                return
            }
        } catch {
            saveErrorMessage = "Unable to load today's entry."
            return
        }

        let now = nowProvider()
        let newEntry = JournalEntry(
            entryDate: dayStart,
            createdAt: now,
            updatedAt: now
        )
        context.insert(newEntry)
        hydrate(from: newEntry)
        persistChanges()
    }

    private func hydrate(from entry: JournalEntry) {
        journalEntry = entry
        isHydrating = true
        defer { isHydrating = false }

        entryDate = entry.entryDate
        gratitudes = JournalViewModel.padded(entry.gratitudes)
        needs = JournalViewModel.padded(entry.needs)
        people = JournalViewModel.padded(entry.people)
        bibleNotes = entry.bibleNotes
        reflections = entry.reflections
    }

    private func persistChanges() {
        guard !isHydrating, let context = modelContext, let entry = journalEntry else { return }

        entry.gratitudes = cleaned(gratitudes)
        entry.needs = cleaned(needs)
        entry.people = cleaned(people)
        entry.bibleNotes = bibleNotes.trimmingCharacters(in: .whitespacesAndNewlines)
        entry.reflections = reflections.trimmingCharacters(in: .whitespacesAndNewlines)
        entry.updatedAt = nowProvider()
        entry.completedAt = isCompleteEnough(entry: entry) ? (entry.completedAt ?? nowProvider()) : nil

        do {
            try context.save()
            saveErrorMessage = nil
        } catch {
            saveErrorMessage = "Unable to save your journal entry."
        }
    }

    private func scheduleAutosave() {
        guard !isHydrating else { return }
        autosaveTrigger.send(())
    }

    private func cleaned(_ values: [String]) -> [String] {
        values
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private func isCompleteEnough(entry: JournalEntry) -> Bool {
        !entry.gratitudes.isEmpty &&
        !entry.needs.isEmpty &&
        !entry.people.isEmpty &&
        !entry.bibleNotes.isEmpty &&
        !entry.reflections.isEmpty
    }

    private static func padded(_ values: [String]) -> [String] {
        var normalized = values
        if normalized.count > slotCount {
            normalized = Array(normalized.prefix(slotCount))
        }

        if normalized.count < slotCount {
            normalized.append(contentsOf: Array(repeating: "", count: slotCount - normalized.count))
        }
        return normalized
    }

    var completedToday: Bool {
        guard let entry = journalEntry else { return false }
        return isCompleteEnough(entry: entry)
    }

    func updateGratitudes(_ values: [String]) {
        gratitudes = JournalViewModel.padded(values)
        scheduleAutosave()
    }

    func updateNeeds(_ values: [String]) {
        needs = JournalViewModel.padded(values)
        scheduleAutosave()
    }

    func updatePeople(_ values: [String]) {
        people = JournalViewModel.padded(values)
        scheduleAutosave()
    }

    func updateBibleNotes(_ value: String) {
        bibleNotes = value
        scheduleAutosave()
    }

    func updateReflections(_ value: String) {
        reflections = value
        scheduleAutosave()
    }

    func exportSnapshot() -> JournalExportPayload {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        let dateStr = formatter.string(from: entryDate)
        return JournalExportPayload(
            dateFormatted: dateStr,
            gratitudes: cleaned(gratitudes),
            needs: cleaned(needs),
            people: cleaned(people),
            bibleNotes: bibleNotes.trimmingCharacters(in: .whitespacesAndNewlines),
            reflections: reflections.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }
}
