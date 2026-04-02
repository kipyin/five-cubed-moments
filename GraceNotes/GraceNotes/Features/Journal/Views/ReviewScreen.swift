import SwiftUI
import SwiftData

/// Single active “browse all” presentation. Two separate `sheet(item:)` branches can race on some
/// runtimes (e.g. iOS 18 + small devices), showing the recurring sheet when opening Trending browse.
private enum ReviewBrowseSheet: Identifiable {
    case mostRecurring(MostRecurringBrowsePayload)
    case trending(TrendingBrowsePayload)

    var id: UUID {
        switch self {
        case .mostRecurring(let payload):
            return payload.id
        case .trending(let payload):
            return payload.id
        }
    }
}

struct ReviewScreen: View {
    @Query(sort: \JournalEntry.entryDate, order: .reverse) private var entries: [JournalEntry]
    @AppStorage(ReviewWeekBoundaryPreference.userDefaultsKey)
    private var reviewWeekBoundaryRawValue = ReviewWeekBoundaryPreference.defaultValue.rawValue
    @AppStorage(PastStatisticsIntervalPreference.appStorageKey)
    private var pastStatisticsIntervalEncoded = ""
    @State private var reviewInsights: ReviewInsights?
    @State private var isLoadingInsights = false
    @State private var lastInsightsRefreshKey: ReviewInsightsRefreshKey?
    @State private var mostRecurringThemeDrilldown: ReviewThemeDrilldownPayload?
    @State private var browseSheet: ReviewBrowseSheet?
    @State private var trendingThemeDrilldown: ReviewThemeDrilldownPayload?
    @EnvironmentObject private var appNavigation: AppNavigationModel

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

    private var mostRecurringBrowseBinding: Binding<MostRecurringBrowsePayload?> {
        Binding(
            get: {
                guard case .mostRecurring(let payload) = browseSheet else { return nil }
                return payload
            },
            set: { newValue in
                if let newValue {
                    browseSheet = .mostRecurring(newValue)
                } else if case .mostRecurring = browseSheet {
                    browseSheet = nil
                }
            }
        )
    }

    private var trendingBrowseBinding: Binding<TrendingBrowsePayload?> {
        Binding(
            get: {
                guard case .trending(let payload) = browseSheet else { return nil }
                return payload
            },
            set: { newValue in
                if let newValue {
                    browseSheet = .trending(newValue)
                } else if case .trending = browseSheet {
                    browseSheet = nil
                }
            }
        )
    }

    var body: some View {
        Group {
            if entries.isEmpty && !isUiTestingExperience {
                emptyState
            } else {
                historyList
            }
        }
        .navigationTitle(String(localized: "Past"))
        .background(AppTheme.reviewBackground)
        .onAppear {
            PerformanceTrace.instant("ReviewScreen.onAppear")
        }
        .task(id: currentInsightsRefreshKey) {
            await hydrateReviewInsightsFromCacheIfNeeded()
            await refreshReviewInsights()
        }
        .sheet(item: $mostRecurringThemeDrilldown) { payload in
            ThemeDrilldownSheet(payload: payload)
        }
        .sheet(item: $trendingThemeDrilldown) { payload in
            ThemeDrilldownSheet(payload: payload)
        }
        .sheet(item: $browseSheet, onDismiss: {
            browseSheet = nil
        }, content: { sheet in
            Group {
                switch sheet {
                case .mostRecurring(let payload):
                    MostRecurringBrowseSheetContainer(
                        themes: payload.themes,
                        referenceDate: payload.referenceDate,
                        calendar: payload.calendar
                    )
                case .trending(let payload):
                    TrendingBrowseSheetContainer(buckets: payload.buckets)
                }
            }
            .id(sheet.id)
        })
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
        }
        .listStyle(.insetGrouped)
        .listRowSpacing(10)
        .scrollContentBackground(.hidden)
        .background(AppTheme.reviewBackground)
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: AppTheme.spacingSection + AppTheme.floatingTabBarClearance)
        }
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
                browseAllPayload: mostRecurringBrowseBinding,
                insights: reviewInsights,
                isLoading: isLoadingInsights
            )
            .listRowInsets(EdgeInsets(top: 2, leading: 0, bottom: 6, trailing: 0))
            .listRowBackground(AppTheme.reviewBackground)

            ReviewTrendingCard(
                themeDrilldown: $trendingThemeDrilldown,
                browseAllPayload: trendingBrowseBinding,
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

    @MainActor
    private func refreshReviewInsights() async {
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

    private func hydrateReviewInsightsFromCacheIfNeeded() async {
        guard !entries.isEmpty else { return }
        guard reviewInsights == nil else { return }
        reviewInsights = await reviewInsightsCache.insights(
            forWeekStart: currentReviewPeriod.lowerBound,
            calendar: calendar,
            weekBoundaryPreferenceRawValue: reviewWeekBoundaryRawValue,
            pastStatisticsIntervalToken: pastStatisticsInterval.cacheKeyToken
        )
    }
}
