import SwiftData
import SwiftUI

// MARK: - Navigation (issue #253)

/// Ordering for Past “Days you wrote” sheet paging: **global** distinct journal days, oldest → newest.
/// Horizontal paging is enabled only when opening from the rhythm strip (not search).
enum PastJournalDayNavigation {
    /// Distinct calendar day starts for every persisted journal row, sorted ascending.
    static func sortedDistinctDayStarts(from entries: [Journal], calendar: Calendar) -> [Date] {
        let unique = Set(entries.map { calendar.startOfDay(for: $0.entryDate) })
        return unique.sorted()
    }

    static func indexMatchingDay(dayStart: Date, in sortedDays: [Date], calendar: Calendar) -> Int? {
        let normalized = calendar.startOfDay(for: dayStart)
        return sortedDays.firstIndex { calendar.isDate($0, inSameDayAs: normalized) }
    }
}

// MARK: - Sheet payload + host

struct ReviewJournalDaySheetItem: Identifiable, Equatable {
    let id: String
    let entryDate: Date
    /// When non-nil and count > 1, enables horizontal paging (rhythm strip only; issue #253).
    let navigableDayStarts: [Date]?

    init(dayStart: Date, calendar: Calendar, navigableDayStarts: [Date]?) {
        let normalized = calendar.startOfDay(for: dayStart)
        entryDate = normalized
        let parts = calendar.dateComponents([.year, .month, .day], from: normalized)
        let year = parts.year ?? 0
        let month = parts.month ?? 0
        let day = parts.day ?? 0
        id = "\(year)-\(month)-\(day)"
        self.navigableDayStarts = navigableDayStarts
    }
}

struct ReviewJournalDaySheetHost: View {
    let item: ReviewJournalDaySheetItem

    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var selectedIndex: Int

    init(item: ReviewJournalDaySheetItem, calendar: Calendar) {
        self.item = item
        let days = item.navigableDayStarts ?? []
        let startIndex = PastJournalDayNavigation.indexMatchingDay(
            dayStart: item.entryDate,
            in: days,
            calendar: calendar
        ) ?? 0
        _selectedIndex = State(initialValue: startIndex)
    }

    private var navigableDays: [Date] {
        item.navigableDayStarts ?? []
    }

    private var isPagingEnabled: Bool {
        navigableDays.count > 1
    }

    var body: some View {
        NavigationStack {
            Group {
                if isPagingEnabled, reduceMotion {
                    pagedContentReduceMotion
                } else if isPagingEnabled {
                    pagedContentTabView
                } else {
                    JournalScreen(entryDate: item.entryDate)
                }
            }
            .toolbar {
                if isPagingEnabled {
                    ToolbarItem(placement: .topBarLeading) {
                        dayNavigationButtons
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    PastToolbarDoneButton(
                        action: { dismiss() },
                        appearance: .journal
                    )
                }
            }
        }
    }

    @ViewBuilder
    private var pagedContentTabView: some View {
        TabView(selection: $selectedIndex) {
            ForEach(0..<navigableDays.count, id: \.self) { index in
                JournalScreen(entryDate: navigableDays[index])
                    .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }

    private var pagedContentReduceMotion: some View {
        JournalScreen(entryDate: navigableDays[selectedIndex])
            .id(navigableDays[selectedIndex].timeIntervalSince1970)
    }

    private var dayNavigationButtons: some View {
        HStack(spacing: AppTheme.spacingRegular) {
            Button {
                moveToAdjacentDay(offset: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(AppTheme.warmPaperBody.weight(.semibold))
                    .foregroundStyle(AppTheme.accent)
            }
            .buttonStyle(PastToolbarDoneButtonStyle())
            .disabled(selectedIndex <= 0)
            .accessibilityLabel(String(localized: "past.journalDay.previous"))
            .accessibilityIdentifier("PastJournalDayPrevious")

            Button {
                moveToAdjacentDay(offset: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(AppTheme.warmPaperBody.weight(.semibold))
                    .foregroundStyle(AppTheme.accent)
            }
            .buttonStyle(PastToolbarDoneButtonStyle())
            .disabled(selectedIndex >= navigableDays.count - 1)
            .accessibilityLabel(String(localized: "past.journalDay.next"))
            .accessibilityIdentifier("PastJournalDayNext")
        }
    }

    private func moveToAdjacentDay(offset: Int) {
        let next = selectedIndex + offset
        guard navigableDays.indices.contains(next) else { return }
        if reduceMotion {
            selectedIndex = next
        } else {
            withAnimation {
                selectedIndex = next
            }
        }
    }
}
