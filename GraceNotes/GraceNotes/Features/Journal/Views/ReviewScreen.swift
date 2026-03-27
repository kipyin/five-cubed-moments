import SwiftUI
import SwiftData

struct ReviewScreen: View {
    @Query(sort: \JournalEntry.entryDate, order: .reverse) private var entries: [JournalEntry]
    @State private var reviewInsights: ReviewInsights?
    @State private var isLoadingInsights = false
    @State private var lastInsightsRefreshKey: ReviewInsightsRefreshKey?
    @EnvironmentObject private var appNavigation: AppNavigationModel

    private let calendar = Calendar.current
    private let reviewInsightsProvider = ReviewInsightsProvider.shared
    private let reviewInsightsCache = ReviewInsightsCache.shared
    /// When true, keep Review list chrome even with zero entries so UI tests can navigate.
    private let isUiTestingExperience: Bool

    init() {
        let isUiTesting = ProcessInfo.graceNotesIsRunningUITests
        isUiTestingExperience = isUiTesting
    }

    private var currentInsightsRefreshKey: ReviewInsightsRefreshKey {
        ReviewInsightsRefreshKey(
            weekStart: currentReviewPeriod.lowerBound,
            entrySnapshots: weeklyEntriesForRefresh.map {
                ReviewEntrySnapshot(id: $0.id, updatedAt: $0.updatedAt)
            }
        )
    }

    private var currentReviewPeriod: Range<Date> {
        ReviewInsightsPeriod.currentPeriod(containing: Date(), calendar: calendar)
    }

    private var weeklyEntriesForRefresh: [JournalEntry] {
        entries.filter { currentReviewPeriod.contains($0.entryDate) }
    }

    var body: some View {
        Group {
            if entries.isEmpty && !isUiTestingExperience {
                emptyState
            } else {
                historyList
            }
        }
        .navigationTitle(String(localized: "Review"))
        .background(AppTheme.reviewBackground)
        .onAppear {
            PerformanceTrace.instant("ReviewScreen.onAppear")
        }
        .task(id: currentInsightsRefreshKey) {
            await hydrateReviewInsightsFromCacheIfNeeded()
            await refreshReviewInsights()
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label(String(localized: "No entries yet"), systemImage: "doc.text")
        } description: {
            Text(String(localized: "Start with today."))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var historyList: some View {
        List {
            insightsSection
            insightsPullToRefreshScrollAssist
        }
        .listStyle(.insetGrouped)
        .listRowSpacing(10)
        .scrollContentBackground(.hidden)
        .background(AppTheme.reviewBackground)
        .refreshable {
            await refreshReviewInsights(force: true)
        }
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: AppTheme.spacingSection + AppTheme.floatingTabBarClearance)
        }
    }

    private var insightsSection: some View {
        Section {
            ReviewSummaryCard(
                insights: reviewInsights,
                isLoading: isLoadingInsights,
                weekJournalEntryCount: weeklyEntriesForRefresh.count,
                onContinueToToday: { appNavigation.selectedTab = .today }
            )
            .listRowInsets(EdgeInsets(top: 2, leading: 0, bottom: 6, trailing: 0))
            .listRowBackground(AppTheme.reviewBackground)
        }
    }

    /// `List.refreshable` only engages when the scroll view can overscroll; a short insights stack often cannot.
    private var insightsPullToRefreshScrollAssist: some View {
        Section {
            Color.clear
                .frame(height: 280)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .accessibilityHidden(true)
        }
    }

    @MainActor
    private func refreshReviewInsights(force: Bool = false) async {
        guard !entries.isEmpty else {
            reviewInsights = nil
            isLoadingInsights = false
            lastInsightsRefreshKey = nil
            return
        }

        let refreshKey = currentInsightsRefreshKey
        let shouldRefresh = ReviewInsightsRefreshPolicy.shouldRefresh(
            force: force,
            hasInsights: reviewInsights != nil,
            previousKey: lastInsightsRefreshKey,
            currentKey: refreshKey
        )
        guard shouldRefresh else { return }

        let previousForForcedRefresh = force ? reviewInsights : nil

        isLoadingInsights = true
        let generatedInsights = await reviewInsightsProvider.generateInsights(
            from: entries,
            referenceDate: Date(),
            calendar: calendar
        )
        guard !Task.isCancelled else {
            isLoadingInsights = false
            return
        }
        if !force, refreshKey != currentInsightsRefreshKey {
            isLoadingInsights = false
            return
        }

        let outcome = reviewInsightsRefreshOutcome(
            force: force,
            previous: previousForForcedRefresh,
            generated: generatedInsights
        )

        reviewInsights = outcome.insights
        await reviewInsightsCache.storeIfEligible(outcome.insights, calendar: calendar)
        if outcome.shouldUpdateCachedRefreshKey {
            lastInsightsRefreshKey = refreshKey
        }
        isLoadingInsights = false
    }

    private func hydrateReviewInsightsFromCacheIfNeeded() async {
        guard !entries.isEmpty else { return }
        guard reviewInsights == nil else { return }
        reviewInsights = await reviewInsightsCache.insights(
            forWeekStart: currentReviewPeriod.lowerBound,
            calendar: calendar
        )
    }

    private func reviewInsightsRefreshOutcome(
        force: Bool,
        previous: ReviewInsights?,
        generated: ReviewInsights
    ) -> ReviewInsightsRefreshPolicy.ForcedRefreshOutcome {
        if force {
            return ReviewInsightsRefreshPolicy.forcedRefreshOutcome(previous: previous, generated: generated)
        }
        return ReviewInsightsRefreshPolicy.ForcedRefreshOutcome(
            insights: generated,
            shouldUpdateCachedRefreshKey: true
        )
    }
}
