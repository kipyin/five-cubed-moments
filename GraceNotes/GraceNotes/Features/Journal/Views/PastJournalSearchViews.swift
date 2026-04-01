import SwiftData
import SwiftUI
import UIKit

enum PastJournalSearchDebouncer {
    @MainActor
    static func runDebouncedSearch(
        query: String,
        calendar: Calendar,
        modelContext: ModelContext,
        updateMatches: @MainActor @escaping ([JournalSearchMatch]) -> Void
    ) async {
        let snapshot = query
        try? await Task.sleep(nanoseconds: 250_000_000)
        guard !Task.isCancelled else { return }
        guard snapshot == query else { return }

        let trimmed = snapshot.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            updateMatches([])
            return
        }

        let repository = JournalRepository(calendar: calendar)
        do {
            let results = try repository.searchMatches(query: trimmed, context: modelContext)
            guard !Task.isCancelled else { return }
            guard snapshot == query else { return }
            updateMatches(results)
        } catch {
            guard snapshot == query else { return }
            updateMatches([])
        }
    }
}

private enum PastSearchListLayout {
    static var rowInsets: EdgeInsets {
        let inset = AppTheme.spacingWide
        return EdgeInsets(top: 2, leading: inset, bottom: 6, trailing: inset)
    }

    static var searchBarRowInsets: EdgeInsets {
        let inset = AppTheme.spacingWide
        return EdgeInsets(top: 6, leading: inset, bottom: 8, trailing: inset)
    }
}

enum PastJournalSearchGrouping {
    static func groups(
        matches: [JournalSearchMatch],
        calendar: Calendar
    ) -> [(day: Date, rows: [JournalSearchMatch])] {
        let grouped = Dictionary(grouping: matches) { calendar.startOfDay(for: $0.entryDate) }
        return grouped.keys.sorted(by: >).map { day in
            let rows = (grouped[day] ?? []).sorted { lhs, rhs in
                if lhs.source != rhs.source {
                    return lhs.source.rawValue < rhs.source.rawValue
                }
                return lhs.content.localizedCaseInsensitiveCompare(rhs.content) == .orderedAscending
            }
            return (day, rows)
        }
    }
}

private struct PastJournalSearchBarChrome<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.body.weight(.medium))
                .foregroundStyle(AppTheme.reviewTextMuted)
                .accessibilityHidden(true)
            content()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .circular)
                .fill(AppTheme.reviewPaper.opacity(0.72))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .circular)
                .strokeBorder(AppTheme.reviewStandardBorder.opacity(0.42), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .circular))
    }
}

struct PastJournalSearchBar: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @Binding var text: String
    private let searchFocus: FocusState<Bool>.Binding?

    init(text: Binding<String>, searchFocus: FocusState<Bool>.Binding? = nil) {
        _text = text
        self.searchFocus = searchFocus
    }

    private var isSearchFocused: Bool {
        searchFocus?.wrappedValue ?? false
    }

    var body: some View {
        PastJournalSearchBarChrome {
            HStack(spacing: 8) {
                Group {
                    if let searchFocus {
                        TextField(String(localized: "Search journal"), text: $text)
                            .focused(searchFocus)
                    } else {
                        TextField(String(localized: "Search journal"), text: $text)
                    }
                }
                .textFieldStyle(.plain)
                .submitLabel(.search)
                .accessibilityLabel(String(localized: "Search journal"))
                .frame(maxWidth: .infinity, alignment: .leading)

                if isSearchFocused {
                    Button(action: dismissSearchControlTapped) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.body.weight(.medium))
                            .foregroundStyle(AppTheme.reviewTextMuted)
                            .symbolRenderingMode(.hierarchical)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(String(localized: "PastSearch.dismissControl.a11yLabel"))
                    .accessibilityHint(String(localized: "PastSearch.dismissControl.a11yHint"))
                    .transition(.opacity.combined(with: .scale(scale: 0.88)))
                }
            }
            .animation(reduceMotion ? nil : .snappy(duration: 0.22), value: isSearchFocused)
        }
    }

    private func dismissSearchControlTapped() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if reduceMotion {
            if !trimmed.isEmpty {
                text = ""
            }
            searchFocus?.wrappedValue = false
        } else {
            withAnimation(.snappy(duration: 0.22)) {
                if !trimmed.isEmpty {
                    text = ""
                }
                searchFocus?.wrappedValue = false
            }
        }
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

struct PastJournalSearchResultsList: View {
    let query: String
    let isAwaitingInput: Bool
    let matches: [JournalSearchMatch]
    let calendar: Calendar
    let onDismissSearchFocus: () -> Void

    private var groupedMatches: [(day: Date, rows: [JournalSearchMatch])] {
        PastJournalSearchGrouping.groups(matches: matches, calendar: calendar)
    }

    private var summaryTitle: String {
        if isAwaitingInput || query.isEmpty {
            String(localized: "Search journal")
        } else {
            query
        }
    }

    private var summarySubtitle: String {
        if isAwaitingInput {
            String(localized: "PastSearch.awaitingInput.subtitle")
        } else if matches.isEmpty {
            String(localized: "PastSearch.noMatches.description")
        } else {
            String(format: String(localized: "PastSearch.matchCountFormat"), matches.count)
        }
    }

    var body: some View {
        Group {
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    Text(summaryTitle)
                        .font(AppTheme.warmPaperHeader)
                        .foregroundStyle(AppTheme.reviewTextPrimary)
                        .lineLimit(3)
                    Text(summarySubtitle)
                        .font(AppTheme.warmPaperBody)
                        .foregroundStyle(AppTheme.reviewTextMuted)
                }
                .padding(.vertical, 2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .onTapGesture {
                    onDismissSearchFocus()
                }
                .listRowInsets(PastSearchListLayout.rowInsets)
                .listRowBackground(AppTheme.reviewBackground)
                .listRowSeparator(.hidden)
            } header: {
                Text(String(localized: "Summary"))
                    .font(AppTheme.warmPaperMeta)
                    .foregroundStyle(AppTheme.reviewTextMuted)
                    .textCase(nil)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onDismissSearchFocus()
                    }
            }

            if !matches.isEmpty {
                Section {
                    ForEach(groupedMatches, id: \.day) { group in
                        Section {
                            ForEach(group.rows) { match in
                                NavigationLink {
                                    JournalScreen(entryDate: match.entryDate)
                                } label: {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(match.source.localizedJournalSurfaceTitle)
                                            .font(AppTheme.warmPaperMetaEmphasis.weight(.semibold))
                                            .foregroundStyle(AppTheme.reviewTextPrimary)
                                        Text(match.content)
                                            .font(AppTheme.warmPaperBody)
                                            .foregroundStyle(AppTheme.reviewTextPrimary)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, 2)
                                }
                                .buttonStyle(.plain)
                                .accessibilityElement(children: .combine)
                                .accessibilityLabel(rowAccessibilityLabel(day: group.day, match: match))
                                .accessibilityHint(String(localized: "ThemeDrilldown.openEntry.a11yHint"))
                                .listRowInsets(PastSearchListLayout.rowInsets)
                                .listRowSeparator(.hidden)
                            }
                        } header: {
                            Text(group.day.formatted(date: .abbreviated, time: .omitted))
                                .font(AppTheme.warmPaperMeta)
                                .foregroundStyle(AppTheme.reviewTextMuted)
                                .textCase(nil)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    onDismissSearchFocus()
                                }
                        }
                    }
                } header: {
                    Text(String(localized: "Matching writing surfaces"))
                        .font(AppTheme.warmPaperMeta)
                        .foregroundStyle(AppTheme.reviewTextMuted)
                        .textCase(nil)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onDismissSearchFocus()
                        }
                }
            }
        }
    }

    private func rowAccessibilityLabel(day: Date, match: JournalSearchMatch) -> String {
        let dayText = day.formatted(date: .abbreviated, time: .omitted)
        return [dayText, match.source.localizedJournalSurfaceTitle, match.content].joined(separator: ", ")
    }
}
