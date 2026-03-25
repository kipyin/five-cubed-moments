import SwiftUI
import SwiftData
import UIKit

// This screen still hosts multiple interaction surfaces while the UI refresh is in progress.

enum JournalScreenLayout {
    static let journalScrollCoordinateSpaceName = "journalMainScroll"
    static let unlockToastScrollDismissThreshold: CGFloat = 20
}

struct JournalScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

extension View {
    @ViewBuilder
    func journalDismissUnlockToastOnTapOutside(_ isPresented: Bool, dismiss: @escaping () -> Void) -> some View {
        if isPresented {
            self.simultaneousGesture(TapGesture().onEnded { _ in dismiss() })
        } else {
            self
        }
    }
}

// Chip sections and modifiers keep this type large; further extraction would split `body` across files.
// swiftlint:disable type_body_length
struct JournalScreen: View {
    @EnvironmentObject var appNavigation: AppNavigationModel
    @Environment(\.modelContext) var modelContext
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var viewModel = JournalViewModel()
    @State var shareableImage: ShareableImage?
    @State var showShareError = false
    @State var showSavedToPhotosToast = false
    @State var savedToPhotosDismissTask: Task<Void, Never>?
    @State var hasTrackedInitialLoad = false
    @State var gratitudeSummarizationTask: Task<Void, Never>?
    @State var needSummarizationTask: Task<Void, Never>?
    @State var personSummarizationTask: Task<Void, Never>?
    @State var statusCelebrationDismissTask: Task<Void, Never>?
    @State var celebratingLevel: JournalCompletionLevel?
    @State var hasInitializedCompletionTracking = false
    @State var previousCompletionLevel: JournalCompletionLevel = .soil
    @State var unlockToastLevel: JournalCompletionLevel?
    @State var unlockToastMilestone: JournalUnlockMilestoneHighlight = .none
    @State var journalScrollOffsetY: CGFloat = 0
    @State var unlockToastScrollBaseline: CGFloat?
    @State var tutorialProgress = JournalTutorialProgress()
    @State var showPostSeedJourney = false
    @State var postSeedJourneySkipsCongratulations = false
    @AppStorage(JournalOnboardingStorageKeys.completedGuidedJournal) var hasCompletedGuidedJournal = false
    @AppStorage(JournalOnboardingStorageKeys.hasSeenPostSeedJourney) var hasSeenPostSeedJourney = false
    @AppStorage(JournalOnboardingStorageKeys.dismissedRemindersSuggestion)
    var dismissedRemindersSuggestion = false
    @AppStorage(JournalOnboardingStorageKeys.dismissedAISuggestion)
    var dismissedAISuggestion = false
    @AppStorage(JournalOnboardingStorageKeys.dismissedICloudSuggestion)
    var dismissedICloudSuggestion = false
    @AppStorage(JournalOnboardingStorageKeys.openedRemindersSuggestion)
    var openedRemindersSuggestion = false
    @AppStorage(JournalOnboardingStorageKeys.openedAISuggestion)
    var openedAISuggestion = false
    @AppStorage(JournalOnboardingStorageKeys.openedICloudSuggestion)
    var openedICloudSuggestion = false
    @AppStorage(SummarizerProvider.useCloudUserDefaultsKey) var useCloudSummarization = false
    @AppStorage(PersistenceController.iCloudSyncEnabledKey) var isICloudSyncEnabled = false
    @AppStorage(JournalTutorialStorageKeys.dismissedSeedGuidance) var dismissedSeedGuidance = false
    @AppStorage(JournalTutorialStorageKeys.dismissedHarvestGuidance) var dismissedHarvestGuidance = false

    @State var gratitudeInput = ""
    @State var needInput = ""
    @State var personInput = ""

    @State var editingGratitudeIndex: Int?
    @State var editingNeedIndex: Int?
    @State var editingPersonIndex: Int?
    @State var isGratitudeTransitioning = false
    @State var isNeedTransitioning = false
    @State var isPersonTransitioning = false
    @FocusState var isGratitudeInputFocused: Bool
    @FocusState var isNeedInputFocused: Bool
    @FocusState var isPersonInputFocused: Bool
    @FocusState var isReadingNotesFocused: Bool
    @FocusState var isReflectionsFocused: Bool

    var entryDate: Date?
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.todaySectionSpacing) {
                DateSectionView(
                    completionLevel: viewModel.completionLevel,
                    celebratingLevel: celebratingLevel
                )

                if !onboardingPresentation.isGuidanceActive,
                   let hintKind = JournalTutorialHintPresentation.hintKind(
                    entryDate: entryDate,
                    completionLevel: viewModel.completionLevel,
                    chipsFilledCount: viewModel.chipsFilledCount,
                    dismissedSeedGuidance: dismissedSeedGuidance,
                    dismissedHarvestGuidance: dismissedHarvestGuidance
                ) {
                    JournalTutorialHintView(kind: hintKind) {
                        switch hintKind {
                        case .seed:
                            dismissedSeedGuidance = true
                        case .harvest:
                            dismissedHarvestGuidance = true
                        }
                    }
                }

                if let onboardingSuggestion {
                    JournalOnboardingSuggestionView(
                        title: suggestionTitle(for: onboardingSuggestion),
                        message: suggestionMessage(for: onboardingSuggestion),
                        primaryActionTitle: String(localized: "Open Settings"),
                        secondaryActionTitle: String(localized: "Not now"),
                        onPrimaryAction: { openSettings(for: onboardingSuggestion) },
                        onSecondaryAction: { dismissSuggestion(onboardingSuggestion) }
                    )
                }

                VStack(alignment: .leading, spacing: AppTheme.todayClusterSpacing) {
                    SequentialSectionView(
                        title: String(localized: "Gratitudes"),
                        guidanceTitle: onboardingPresentation.sectionGuidance(for: .gratitude)?.title,
                        guidanceMessage: onboardingPresentation.sectionGuidance(for: .gratitude)?.message,
                        guidanceMessageSecondary: onboardingPresentation.sectionGuidance(for: .gratitude)?
                            .messageSecondary,
                        items: viewModel.gratitudes,
                        placeholder: String(localized: "What's one thing you're grateful for?"),
                        slotCount: JournalViewModel.slotCount,
                        inputAccessibilityIdentifier: "Gratitude 1",
                        chipAccessibilityIdentifierPrefix: ProcessInfo.graceNotesIsRunningUITests
                            ? "JournalGratitudeChip"
                            : nil,
                        addChipAccessibilityIdentifier: ProcessInfo.graceNotesIsRunningUITests
                            ? "JournalSectionAdd.gratitude"
                            : nil,
                        onboardingState: onboardingPresentation.state(for: .gratitude),
                        isTransitioning: isGratitudeTransitioning,
                        inputText: $gratitudeInput,
                        editingIndex: editingGratitudeIndex,
                        inputFocus: $isGratitudeInputFocused,
                        onInputFocusLost: { commitChipDraftOnInputFocusLost(section: .gratitude) },
                        onSubmit: submitGratitude,
                        onChipTap: { index in chipTapped(section: .gratitude, index: index) },
                        onRenameChip: { index, label in renameChip(section: .gratitude, index: index, label: label) },
                        onMoveChip: { from, toOffset in moveChip(section: .gratitude, from: from, toOffset: toOffset) },
                        onDeleteChip: { index in deleteChip(section: .gratitude, index: index) },
                        onAddNew: { addNewTapped(section: .gratitude) }
                    )

                    SequentialSectionView(
                        title: String(localized: "Needs"),
                        guidanceTitle: onboardingPresentation.sectionGuidance(for: .need)?.title,
                        guidanceMessage: onboardingPresentation.sectionGuidance(for: .need)?.message,
                        items: viewModel.needs,
                        placeholder: String(localized: "What do you need today?"),
                        slotCount: JournalViewModel.slotCount,
                        inputAccessibilityIdentifier: "Need 1",
                        addChipAccessibilityIdentifier: ProcessInfo.graceNotesIsRunningUITests
                            ? "JournalSectionAdd.need"
                            : nil,
                        onboardingState: onboardingPresentation.state(for: .need),
                        isTransitioning: isNeedTransitioning,
                        inputText: $needInput,
                        editingIndex: editingNeedIndex,
                        inputFocus: $isNeedInputFocused,
                        onInputFocusLost: { commitChipDraftOnInputFocusLost(section: .need) },
                        onSubmit: submitNeed,
                        onChipTap: { index in chipTapped(section: .need, index: index) },
                        onRenameChip: { index, label in renameChip(section: .need, index: index, label: label) },
                        onMoveChip: { from, toOffset in moveChip(section: .need, from: from, toOffset: toOffset) },
                        onDeleteChip: { index in deleteChip(section: .need, index: index) },
                        onAddNew: { addNewTapped(section: .need) }
                    )

                    SequentialSectionView(
                        title: String(localized: "People in Mind"),
                        guidanceTitle: onboardingPresentation.sectionGuidance(for: .person)?.title,
                        guidanceMessage: onboardingPresentation.sectionGuidance(for: .person)?.message,
                        items: viewModel.people,
                        placeholder: String(localized: "Who are you thinking of today?"),
                        slotCount: JournalViewModel.slotCount,
                        inputAccessibilityIdentifier: "Person 1",
                        addChipAccessibilityIdentifier: ProcessInfo.graceNotesIsRunningUITests
                            ? "JournalSectionAdd.person"
                            : nil,
                        onboardingState: onboardingPresentation.state(for: .person),
                        isTransitioning: isPersonTransitioning,
                        inputText: $personInput,
                        editingIndex: editingPersonIndex,
                        inputFocus: $isPersonInputFocused,
                        onInputFocusLost: { commitChipDraftOnInputFocusLost(section: .person) },
                        onSubmit: submitPerson,
                        onChipTap: { index in chipTapped(section: .person, index: index) },
                        onRenameChip: { index, label in renameChip(section: .person, index: index, label: label) },
                        onMoveChip: { from, toOffset in moveChip(section: .person, from: from, toOffset: toOffset) },
                        onDeleteChip: { index in deleteChip(section: .person, index: index) },
                        onAddNew: { addNewTapped(section: .person) }
                    )
                }
                .padding(.top, AppTheme.spacingTight)

                VStack(alignment: .leading, spacing: AppTheme.todayNotesSpacing) {
                    EditableTextSection(
                        title: String(localized: "Reading Notes"),
                        guidanceTitle: onboardingPresentation.sectionGuidance(for: .readingNotes)?.title,
                        guidanceMessage: onboardingPresentation.sectionGuidance(for: .readingNotes)?.message,
                        guidanceMessageSecondary: onboardingPresentation.sectionGuidance(for: .readingNotes)?
                            .messageSecondary,
                        text: Binding(
                            get: { viewModel.readingNotes },
                            set: { viewModel.updateReadingNotes($0) }
                        ),
                        onboardingState: onboardingPresentation.state(for: .readingNotes),
                        inputFocus: $isReadingNotesFocused
                    )
                    EditableTextSection(
                        title: String(localized: "Reflections"),
                        text: Binding(
                            get: { viewModel.reflections },
                            set: { viewModel.updateReflections($0) }
                        ),
                        onboardingState: onboardingPresentation.state(for: .reflections),
                        inputFocus: $isReflectionsFocused
                    )
                }
                .padding(.top, AppTheme.spacingTight)

                if let saveErrorMessage = viewModel.saveErrorMessage {
                    Text(saveErrorMessage)
                        .font(AppTheme.warmPaperBody)
                        .foregroundStyle(AppTheme.journalError)
                }
            }
            .padding(.horizontal, AppTheme.todayHorizontalPadding)
            .padding(.top, AppTheme.todayTopPadding)
            .padding(.bottom, AppTheme.todayBottomPadding)
            .background(journalScrollOffsetReader)
            .journalDismissUnlockToastOnTapOutside(unlockToastLevel != nil) {
                dismissUnlockToastIfNeeded()
            }
        }
        .coordinateSpace(name: JournalScreenLayout.journalScrollCoordinateSpaceName)
        .onPreferenceChange(JournalScrollOffsetPreferenceKey.self) { offsetY in
            journalScrollOffsetY = offsetY
            if unlockToastLevel != nil, let baseline = unlockToastScrollBaseline {
                if abs(offsetY - baseline) > JournalScreenLayout.unlockToastScrollDismissThreshold {
                    dismissUnlockToastIfNeeded()
                }
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .scrollContentBackground(.hidden)
        .background(AppTheme.journalBackground)
        .navigationTitle(navigationTitle)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    shareTapped()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(AppTheme.outfitSemiboldHeadline)
                }
                .accessibilityLabel("Share")
                .accessibilityIdentifier("Share")
            }
        }
        .sheet(item: $shareableImage) { item in
            ShareSheet(
                activityItems: [item.image],
                applicationActivities: [SaveToPhotosActivity(image: item.image)]
            )
        }
        .alert("Unable to share", isPresented: $showShareError) {
            Button("Dismiss") {
                showShareError = false
            }
        } message: {
            Text("We couldn't create a share image right now. Please try again.")
        }
        .fullScreenCover(isPresented: $showPostSeedJourney) {
            PostSeedJourneyView(
                onFinish: completePostSeedJourney,
                skipsCongratulationsPage: postSeedJourneySkipsCongratulations
            )
        }
        .onChange(of: showPostSeedJourney) { _, isPresented in
            guard isPresented else { return }
            isGratitudeInputFocused = false
            isNeedInputFocused = false
            isPersonInputFocused = false
            isReadingNotesFocused = false
            isReflectionsFocused = false
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
        }
        .overlay {
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                VStack(spacing: AppTheme.spacingTight) {
                    if let toastLevel = unlockToastLevel {
                        HStack {
                            Spacer(minLength: 0)
                            Button {
                                dismissUnlockToastIfNeeded()
                            } label: {
                                JournalUnlockToastView(level: toastLevel, milestoneHighlight: unlockToastMilestone)
                            }
                            .buttonStyle(.plain)
                            .accessibilityHint(String(localized: "Dismiss"))
                            .transition(unlockToastTransition(for: toastLevel))
                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, AppTheme.todayHorizontalPadding)
                    }
                    if showSavedToPhotosToast {
                        SavedToPhotosToastView()
                    }
                }
                .padding(.bottom, AppTheme.spacingSection)
            }
        }
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: AppTheme.spacingSection)
        }
        .onReceive(NotificationCenter.default.publisher(for: .photoSavedToLibrary)) { _ in
            savedToPhotosDismissTask?.cancel()
            withAnimation(.easeInOut(duration: 0.2)) {
                showSavedToPhotosToast = true
            }
            savedToPhotosDismissTask = Task { @MainActor in
                try? await Task.sleep(for: .seconds(2.5))
                withAnimation(.easeInOut(duration: 0.2)) {
                    showSavedToPhotosToast = false
                }
            }
        }
        .onDisappear {
            gratitudeSummarizationTask?.cancel()
            needSummarizationTask?.cancel()
            personSummarizationTask?.cancel()
            statusCelebrationDismissTask?.cancel()
        }
        .onChange(of: onboardingPresentation.step) { _, newStep in
            focusOnboardingStepIfNeeded(newStep)
        }
        .onChange(of: viewModel.completionLevel) { _, newLevel in
            if !hasInitializedCompletionTracking {
                previousCompletionLevel = newLevel
                hasInitializedCompletionTracking = true
                syncGuidedJournalCompletionIfNeeded(for: newLevel)
                evaluatePostSeedJourneyIfNeeded(for: newLevel)
                return
            }

            let previousRank = previousCompletionLevel.tutorialCompletionRank
            let newRank = newLevel.tutorialCompletionRank

            if newRank > previousRank, newLevel != .soil {
                let unlockOutcome = JournalTutorialUnlockEvaluator.outcome(
                    previousRank: previousRank,
                    newRank: newRank,
                    newLevel: newLevel,
                    hasCelebratedFirstSeed: tutorialProgress.hasCelebratedFirstSeed,
                    hasCelebratedFirstHarvest: tutorialProgress.hasCelebratedFirstHarvest
                )
                triggerStatusCelebration(for: newLevel)
                let suppressSeedUnlockToast = JournalTodayOrientationPolicy.shouldSuppressSeedUnlockToast(
                    isTodayEntry: entryDate == nil,
                    newLevel: newLevel,
                    hasSeenPostSeedJourney: hasSeenPostSeedJourney
                )
                if !suppressSeedUnlockToast {
                    presentUnlockToast(for: newLevel, milestoneHighlight: unlockOutcome.milestoneHighlight)
                }
                tutorialProgress.applyRecording(from: unlockOutcome)
            } else if newRank < previousRank {
                statusCelebrationDismissTask?.cancel()
                celebratingLevel = nil
                let dismissingLevel = unlockToastLevel
                let fallbackExit = Animation.easeOut(duration: 0.16)
                let toastExit = reduceMotion
                    ? nil
                    : dismissingLevel.map { AppTheme.unlockToastExitAnimation(for: $0) } ?? fallbackExit
                withAnimation(toastExit) {
                    unlockToastLevel = nil
                    unlockToastMilestone = .none
                    unlockToastScrollBaseline = nil
                }
            }

            previousCompletionLevel = newLevel
            syncGuidedJournalCompletionIfNeeded(for: newLevel)
            evaluatePostSeedJourneyIfNeeded(for: newLevel)
        }
        .task {
            if !hasTrackedInitialLoad {
                hasTrackedInitialLoad = true
                PerformanceTrace.instant("JournalScreen.firstTaskStarted")
            }
            let loadTrace = PerformanceTrace.begin("JournalScreen.loadTask")
            if let date = entryDate {
                viewModel.loadEntry(for: date, using: modelContext)
            } else {
                viewModel.loadTodayIfNeeded(using: modelContext)
                let hadPending051GuidedBranch = UserDefaults.standard.bool(
                    forKey: JournalOnboardingStorageKeys.legacy051GuidedBranchResolution
                )
                JournalOnboardingProgress.resolvePending051GuidedJournalBranch(
                    todayCompletionLevel: viewModel.completionLevel,
                    using: .standard
                )
                if hadPending051GuidedBranch {
                    hasCompletedGuidedJournal = UserDefaults.standard.bool(
                        forKey: JournalOnboardingStorageKeys.completedGuidedJournal
                    )
                }
            }
            previousCompletionLevel = viewModel.completionLevel
            hasInitializedCompletionTracking = true
            syncGuidedJournalCompletionIfNeeded(for: viewModel.completionLevel)
            focusOnboardingStepIfNeeded(onboardingPresentation.step)
            evaluatePostSeedJourneyIfNeeded(for: viewModel.completionLevel)
            PerformanceTrace.end("JournalScreen.loadTask", startedAt: loadTrace)
        }
    }
}
// swiftlint:enable type_body_length

extension JournalScreen {
    init(entryDate: Date? = nil) {
        self.entryDate = entryDate
    }

    fileprivate var navigationTitle: String {
        if let date = entryDate {
            return date.formatted(date: .abbreviated, time: .omitted)
        }
        return String(localized: "Today's entry")
    }
}
