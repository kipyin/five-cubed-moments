import XCTest
import SwiftData
@testable import FiveCubedMoments

@MainActor
final class JournalViewModelTests: XCTestCase {
    private var calendar: Calendar!

    override func setUp() {
        super.setUp()
        calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)
    }

    func test_loadTodayIfNeeded_createsSingleNormalizedEntry() throws {
        let context = try makeInMemoryContext()
        let now = Date(timeIntervalSince1970: 1_742_147_200) // 2025-03-15 12:00:00 UTC
        let vm = JournalViewModel(calendar: calendar, nowProvider: { now })

        vm.loadTodayIfNeeded(using: context)
        vm.loadTodayIfNeeded(using: context)

        let startOfDay = calendar.startOfDay(for: now)
        let nextDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        let descriptor = FetchDescriptor<JournalEntry>(
            predicate: #Predicate { entry in
                entry.entryDate >= startOfDay && entry.entryDate < nextDay
            }
        )

        let entries = try context.fetch(descriptor)
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries[0].entryDate, startOfDay)
    }

    func test_loadEntry_usesExistingEntryForSameDay() throws {
        let context = try makeInMemoryContext()
        let now = Date(timeIntervalSince1970: 1_742_147_200)
        let startOfDay = calendar.startOfDay(for: now)
        let existingEntry = JournalEntry(
            entryDate: startOfDay,
            gratitudes: ["Family"],
            needs: ["Wisdom"],
            people: ["Friend"],
            bibleNotes: "Psalm 23",
            reflections: "Trusting God",
            createdAt: now,
            updatedAt: now
        )
        context.insert(existingEntry)
        try context.save()

        let vm = JournalViewModel(calendar: calendar, nowProvider: { now })
        vm.loadEntry(for: now, using: context)

        XCTAssertEqual(vm.gratitudes[0], "Family")
        XCTAssertEqual(vm.needs[0], "Wisdom")
        XCTAssertEqual(vm.people[0], "Friend")
        XCTAssertEqual(vm.bibleNotes, "Psalm 23")
        XCTAssertEqual(vm.reflections, "Trusting God")
    }

    func test_loadEntry_forPastDate_loadsExistingPastEntry() throws {
        let context = try makeInMemoryContext()
        let now = Date(timeIntervalSince1970: 1_742_147_200) // 2025-03-15
        let pastDate = Date(timeIntervalSince1970: 1_742_056_800) // 2025-03-04
        let startOfPastDay = calendar.startOfDay(for: pastDate)
        let pastEntry = JournalEntry(
            entryDate: startOfPastDay,
            gratitudes: ["Past gratitude"],
            needs: ["Past need"],
            people: ["Past person"],
            bibleNotes: "Past notes",
            reflections: "Past reflection",
            createdAt: pastDate,
            updatedAt: pastDate
        )
        context.insert(pastEntry)
        try context.save()

        let vm = JournalViewModel(calendar: calendar, nowProvider: { now })
        vm.loadEntry(for: pastDate, using: context)

        XCTAssertEqual(vm.gratitudes[0], "Past gratitude")
        XCTAssertEqual(vm.needs[0], "Past need")
        XCTAssertEqual(vm.people[0], "Past person")
        XCTAssertEqual(vm.bibleNotes, "Past notes")
        XCTAssertEqual(vm.reflections, "Past reflection")
    }

    func test_loadEntry_switchingDates_hydratesCorrectly() throws {
        let context = try makeInMemoryContext()
        let now = Date(timeIntervalSince1970: 1_742_147_200)
        let pastDate = Date(timeIntervalSince1970: 1_742_056_800)
        let startOfToday = calendar.startOfDay(for: now)
        let startOfPastDay = calendar.startOfDay(for: pastDate)

        let todayEntry = JournalEntry(
            entryDate: startOfToday,
            gratitudes: ["Today"],
            needs: [],
            people: [],
            bibleNotes: "",
            reflections: "",
            createdAt: now,
            updatedAt: now
        )
        let pastEntry = JournalEntry(
            entryDate: startOfPastDay,
            gratitudes: ["Past"],
            needs: [],
            people: [],
            bibleNotes: "",
            reflections: "",
            createdAt: pastDate,
            updatedAt: pastDate
        )
        context.insert(todayEntry)
        context.insert(pastEntry)
        try context.save()

        let vm = JournalViewModel(calendar: calendar, nowProvider: { now })
        vm.loadTodayIfNeeded(using: context)
        XCTAssertEqual(vm.gratitudes[0], "Today")

        vm.loadEntry(for: pastDate, using: context)
        XCTAssertEqual(vm.gratitudes[0], "Past")
    }

    func test_exportSnapshot_trimsTextAndOmitsEmptyStrings() throws {
        let context = try makeInMemoryContext()
        let now = Date(timeIntervalSince1970: 1_742_147_200)
        let vm = JournalViewModel(calendar: calendar, nowProvider: { now })

        vm.loadEntry(for: now, using: context)
        vm.updateGratitudes(["  Family  ", "", "  ", "", ""])
        vm.updateNeeds(["Peace", "", "", "", ""])
        vm.updatePeople(["Alice", "", "", "", ""])
        vm.updateBibleNotes("  Matthew 5  ")
        vm.updateReflections("  Be patient today  ")

        let payload = vm.exportSnapshot()

        XCTAssertEqual(payload.gratitudes, ["Family"])
        XCTAssertEqual(payload.needs, ["Peace"])
        XCTAssertEqual(payload.people, ["Alice"])
        XCTAssertEqual(payload.bibleNotes, "Matthew 5")
        XCTAssertEqual(payload.reflections, "Be patient today")
    }

    func test_exportSnapshot_partialEntry_producesValidPayload() throws {
        let context = try makeInMemoryContext()
        let now = Date(timeIntervalSince1970: 1_742_147_200)
        let vm = JournalViewModel(calendar: calendar, nowProvider: { now })

        vm.loadEntry(for: now, using: context)
        vm.updateGratitudes(["One gratitude", "", "", "", ""])
        vm.updateNeeds([])
        vm.updatePeople([])

        let payload = vm.exportSnapshot()

        XCTAssertEqual(payload.gratitudes, ["One gratitude"])
        XCTAssertEqual(payload.needs, [])
        XCTAssertEqual(payload.people, [])
        XCTAssertTrue(payload.bibleNotes.isEmpty)
        XCTAssertTrue(payload.reflections.isEmpty)
        XCTAssertFalse(payload.dateFormatted.isEmpty)
    }

    func test_updatesPersistAfterDebouncedAutosave() async throws {
        let context = try makeInMemoryContext()
        let now = Date(timeIntervalSince1970: 1_742_147_200)
        let vm = JournalViewModel(calendar: calendar, nowProvider: { now })

        vm.loadEntry(for: now, using: context)
        vm.updateGratitudes(["  Family  ", "", "", "", ""])
        vm.updateNeeds(["Peace", "", "", "", ""])
        vm.updatePeople(["Alice", "", "", "", ""])
        vm.updateBibleNotes("  Matthew 5  ")
        vm.updateReflections("  Be patient today  ")

        try await Task.sleep(nanoseconds: 800_000_000)

        let descriptor = FetchDescriptor<JournalEntry>()
        let entries = try context.fetch(descriptor)
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries[0].gratitudes, ["Family"])
        XCTAssertEqual(entries[0].needs, ["Peace"])
        XCTAssertEqual(entries[0].people, ["Alice"])
        XCTAssertEqual(entries[0].bibleNotes, "Matthew 5")
        XCTAssertEqual(entries[0].reflections, "Be patient today")
    }

    private func makeInMemoryContext() throws -> ModelContext {
        let schema = Schema([JournalEntry.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: configuration)
        return ModelContext(container)
    }
}
