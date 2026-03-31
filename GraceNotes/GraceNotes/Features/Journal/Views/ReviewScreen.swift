import SwiftUI
import SwiftData

struct ReviewScreen: View {
    @Query(sort: \JournalEntry.entryDate, order: .reverse) private var entries: [JournalEntry]
    @Environment(\.modelContext) private var modelContext
    @AppStorage(ReviewWeekBoundaryPreference.userDefaultsKey)
    private var reviewWeekBoundaryRawValue = ReviewWeekBoundaryPreference.defaultValue.rawValue
    @AppStorage(PastStatisticsIntervalPreference.appStorageKey)
    private var pastStatisticsIntervalEncoded = ""
    @State private var reviewInsights: ReviewInsights?
    @State private var isLoadingInsights = false
    @State private var lastInsightsRefreshKey: ReviewInsightsRefreshKey?
    @State private var mostRecurringThemeDrilldown: ReviewThemeDrilldownPayload?
    @State private var mostRecurringBrowsePayload: MostRecurringBrowsePayload?
    @State private var trendingThemeDrilldown: ReviewThemeDrilldownPayload?
    @State private var trendingBrowsePayload: TrendingBrowsePayload?
    @State private var journalSearchText = ""
    @State private var journalSearchMatches: [JournalSearchMatch] = []

    private let reviewInsightsProvider = ReviewInsightsProvider.shared
    private let reviewInsightsCache = ReviewInsightsCache.shared
    /// When true, keep Review list chrome even with zero entries so UI tests can navigate.
    private let isUiTestingExperience: Bool

    init() {
        let isUiTesting = ProcessInfo.graceNotesIsRunningUITests
        isUiTestingExperience = isUiTesting
    }

    private var pastStatisticsInterval: PastStatisticsIntervalSelection {
        PastStatisticsIntervalPreference.selection(fromAppStorage: pastStatisticsIntervalEncoded).validated
    }

    private var currentInsightsRefreshKey: ReviewInsightsRefreshKey {
        let now = Date()
        let period = ReviewInsightsPeriod.currentPeriod(containing: now, calendar: calendar)
        return ReviewInsightsRefreshKey(
            weekStart: period.lowerBound,
            entrySnapshots: ReviewInsightsRefreshKey.entrySnapshotsAffectingInsights(
                entries: entries,
                referenceDate: now,
                calendar: calendar,
                pastStatisticsInterval: pastStatisticsInterval,
                currentReviewPeriod: period
            ),
            weekBoundaryPreferenceRawValue: reviewWeekBoundaryRawValue,
            pastStatisticsIntervalToken: pastStatisticsInterval.cacheKeyToken
        )
    }

    private var currentReviewPeriod: Range<Date> {
        ReviewInsightsPeriod.currentPeriod(containing: Date(), calendar: calendar)
    }

    private var calendar: Calendar {
        ReviewWeekBoundaryPreference.resolve(from: reviewWeekBoundaryRawValue)
            .configuredCalendar()
    }

    private var trimmedJournalSearchText: String {
        journalSearchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isShowingJournalSearch: Bool {
        !trimmedJournalSearchText.isEmpty
    }

    var body: some View {
        Group {
            if entries.isEmpty && !isUiTestingExperience {
                emptyStateWithSearch
            } else {
                historyList
            }
        }
        .navigationTitle(String(localized: "Past"))
        .background(AppTheme.reviewBackground)
        .onAppear {
            PerformanceTrace.instant("ReviewScreen.onAppear")
        }
        .task(id: journalSearchText) {
            await runJournalSearchDebounced()
        }
        .task(id: currentInsightsRefreshKey) {
            await hydrateReviewInsightsFromCacheIfNeeded()
            await refreshReviewInsights()
        }
        .sheet(item: $mostRecurringThemeDrilldown) { payload in
            ThemeDrilldownSheet(payload: payload)
        }
        .sheet(item: $mostRecurringBrowsePayload) { payload in
            MostRecurringBrowseSheetContainer(
                themes: payload.themes,
                referenceDate: payload.referenceDate,
                calendar: payload.calendar
            )
        }
        .sheet(item: $trendingThemeDrilldown) { payload in
            ThemeDrilldownSheet(payload: payload)
        }
        .sheet(item: $trendingBrowsePayload) { payload in
            TrendingBrowseSheetContainer(buckets: payload.buckets)
        }
    }

    private var emptyStateWithSearch: some View {
        List {
            pastSearchBarSection
            if isShowingJournalSearch {
                journalSearchResultsContent
            } else {
                Section {
                    ContentUnavailableView {
                        Label(String(localized: "No entries yet"), systemImage: "doc.text")
                    } description: {
                        Text(String(localized: "Start with today."))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                }
                .listRowBackground(AppTheme.reviewBackground)
            }
        }
        .listStyle(.insetGrouped)
        .listRowSpacing(10)
        .scrollContentBackground(.hidden)
        .background(AppTheme.reviewBackground)
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: AppTheme.spacingSection + AppTheme.floatingTabBarClearance)
        }
    }

    private var historyList: some View {
        List {
            pastSearchBarSection
            if isShowingJournalSearch {
                journalSearchResultsContent
            } else {
                insightsSection
            }
        }
        .listStyle(.insetGrouped)
        .listRowSpacing(10)
        .scrollContentBackground(.hidden)
        .background(AppTheme.reviewBackground)
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: AppTheme.spacingSection + AppTheme.floatingTabBarClearance)
        }
    }

    private var pastSearchBarSection: some View {
        Section {
            PastJournalSearchBar(text: $journalSearchText)
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 8, trailing: 16))
                .listRowBackground(AppTheme.reviewBackground)
        }
    }

    private var journalSearchResultsContent: some View {
        PastJournalSearchResultsList(matches: journalSearchMatches, calendar: calendar)
    }

    private var insightsSection: some View {
        Section {
            if reviewInsights != nil || isLoadingInsights {
                ReviewDaysYouWrotePanel(
                    insights: reviewInsights,
                    isLoading: isLoadingInsights
                )
                .listRowInsets(EdgeInsets(top: 2, leading: 0, bottom: 6, trailing: 0))
                .listRowBackground(AppTheme.reviewBackground)

                ReviewHistoryGrowthStagesPanel(
                    insights: reviewInsights,
                    isLoading: isLoadingInsights
                )
                .listRowInsets(EdgeInsets(top: 2, leading: 0, bottom: 6, trailing: 0))
                .listRowBackground(AppTheme.reviewBackground)

                ReviewHistorySectionDistributionPanel(
                    insights: reviewInsights,
                    isLoading: isLoadingInsights
                )
                .listRowInsets(EdgeInsets(top: 2, leading: 0, bottom: 6, trailing: 0))
                .listRowBackground(AppTheme.reviewBackground)
            }

            ReviewMostRecurringCard(
                themeDrilldown: $mostRecurringThemeDrilldown,
                browseAllPayload: $mostRecurringBrowsePayload,
                insights: reviewInsights,
                isLoading: isLoadingInsights
            )
            .listRowInsets(EdgeInsets(top: 2, leading: 0, bottom: 6, trailing: 0))
            .listRowBackground(AppTheme.reviewBackground)

            ReviewTrendingCard(
                themeDrilldown: $trendingThemeDrilldown,
                browseAllPayload: $trendingBrowsePayload,
                insights: reviewInsights,
                isLoading: isLoadingInsights
            )
            .listRowInsets(EdgeInsets(top: 2, leading: 0, bottom: 6, trailing: 0))
            .listRowBackground(AppTheme.reviewBackground)

            ReviewNarrativeSummaryCard(
                insights: reviewInsights,
                isLoading: isLoadingInsights
            )
            .listRowInsets(EdgeInsets(top: 2, leading: 0, bottom: 6, trailing: 0))
            .listRowBackground(AppTheme.reviewBackground)
        }
    }
}

private extension ReviewScreen {
    @MainActor
    func refreshReviewInsights() async {
        guard !entries.isEmpty else {
            reviewInsights = nil
            isLoadingInsights = false
            lastInsightsRefreshKey = nil
            return
        }

        let refreshKey = currentInsightsRefreshKey
        let shouldRefresh = ReviewInsightsRefreshPolicy.shouldRefresh(
            hasInsights: reviewInsights != nil,
            previousKey: lastInsightsRefreshKey,
            currentKey: refreshKey
        )
        guard shouldRefresh else { return }

        isLoadingInsights = true
        let generatedInsights = await reviewInsightsProvider.generateInsights(
            from: entries,
            referenceDate: Date(),
            calendar: calendar,
            pastStatisticsInterval: pastStatisticsInterval
        )
        guard !Task.isCancelled else {
            isLoadingInsights = false
            return
        }
        if refreshKey != currentInsightsRefreshKey {
            isLoadingInsights = false
            return
        }

        reviewInsights = generatedInsights
        await reviewInsightsCache.storeIfEligible(
            generatedInsights,
            calendar: calendar,
            weekBoundaryPreferenceRawValue: reviewWeekBoundaryRawValue,
            pastStatisticsIntervalToken: pastStatisticsInterval.cacheKeyToken
        )
        lastInsightsRefreshKey = refreshKey
        isLoadingInsights = false
    }

    func hydrateReviewInsightsFromCacheIfNeeded() async {
        guard !entries.isEmpty else { return }
        guard reviewInsights == nil else { return }
        reviewInsights = await reviewInsightsCache.insights(
            forWeekStart: currentReviewPeriod.lowerBound,
            calendar: calendar,
            weekBoundaryPreferenceRawValue: reviewWeekBoundaryRawValue,
            pastStatisticsIntervalToken: pastStatisticsInterval.cacheKeyToken
        )
    }

    @MainActor
    func runJournalSearchDebounced() async {
        let snapshot = journalSearchText
        try? await Task.sleep(nanoseconds: 250_000_000)
        guard !Task.isCancelled else { return }
        guard snapshot == journalSearchText else { return }

        let trimmed = snapshot.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            journalSearchMatches = []
            return
        }

        let repository = JournalRepository(calendar: calendar)
        do {
            let matches = try repository.searchMatches(query: trimmed, context: modelContext)
            guard !Task.isCancelled else { return }
            guard snapshot == journalSearchText else { return }
            journalSearchMatches = matches
        } catch {
            guard snapshot == journalSearchText else { return }
            journalSearchMatches = []
        }
    }
}
