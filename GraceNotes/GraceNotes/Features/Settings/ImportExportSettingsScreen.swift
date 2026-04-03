import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ImportExportSettingsScreen: View {
    @Environment(\.modelContext) private var modelContext

    @State private var exportErrorMessage: String?
    @State private var showExportError = false
    @State private var exportFile: ShareableFile?
    @State private var isExportingData = false
    @State private var showImportPicker = false
    @State private var showImportReview = false
    @State private var pendingImportURL: URL?
    @State private var importMode: JournalImportMode = .merge
    @State private var isImportingData = false
    @State private var importErrorMessage: String?
    @State private var showImportError = false
    @State private var importSuccessSummary: JournalDataImportSummary?
    @State private var showImportSuccess = false
    @State private var mergeConflictDays: [Date] = []
    @State private var showMergeConflictResolution = false
    @State private var exportHistory: [BackupExportHistoryEntry] = []
    @State private var scheduledInterval: ScheduledBackupInterval = ScheduledBackupPreferences.interval
    @State private var showScheduledFolderPicker = false
    @State private var scheduledFolderError: String?
    @State private var showScheduledFolderError = false

    private let dataExportService = JournalDataExportService()
    private let dataImportService = JournalDataImportService()

    var body: some View {
        List {
            Section {
                Button {
                    exportJournalData()
                } label: {
                    settingsRow(label: String(localized: "DataPrivacy.importExport.export.json"))
                }
                .buttonStyle(.plain)
                .disabled(isExportingData || isImportingData)
            } header: {
                Text(String(localized: "DataPrivacy.importExport.section.export"))
                    .font(AppTheme.warmPaperMeta)
                    .foregroundStyle(AppTheme.settingsTextMuted)
                    .textCase(nil)
            }

            if !exportHistory.isEmpty {
                Section {
                    ForEach(exportHistory) { entry in
                        VStack(alignment: .leading, spacing: AppTheme.spacingTight / 2) {
                            Text(entry.finishedAt.formatted(date: .abbreviated, time: .shortened))
                                .font(AppTheme.warmPaperBody)
                                .foregroundStyle(AppTheme.settingsTextPrimary)
                            Text(historyDetailLabel(for: entry))
                                .font(AppTheme.warmPaperMeta)
                                .foregroundStyle(AppTheme.settingsTextMuted)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityElement(children: .combine)
                    }
                } header: {
                    Text(String(localized: "DataPrivacy.importExport.section.history"))
                        .font(AppTheme.warmPaperMeta)
                        .foregroundStyle(AppTheme.settingsTextMuted)
                        .textCase(nil)
                }
            }

            Section {
                Picker(String(localized: "DataPrivacy.scheduledBackup.interval.title"), selection: $scheduledInterval) {
                    Text(String(localized: "DataPrivacy.scheduledBackup.interval.off")).tag(ScheduledBackupInterval.off)
                    Text(String(localized: "DataPrivacy.scheduledBackup.interval.daily")).tag(ScheduledBackupInterval.daily)
                    Text(String(localized: "DataPrivacy.scheduledBackup.interval.weekly")).tag(ScheduledBackupInterval.weekly)
                    Text(String(localized: "DataPrivacy.scheduledBackup.interval.biweekly")).tag(ScheduledBackupInterval.biweekly)
                    Text(String(localized: "DataPrivacy.scheduledBackup.interval.monthly")).tag(ScheduledBackupInterval.monthly)
                }
                .font(AppTheme.warmPaperBody)
                .foregroundStyle(AppTheme.settingsTextPrimary)
                .onChange(of: scheduledInterval) { _, newValue in
                    ScheduledBackupPreferences.interval = newValue
                }

                Button {
                    showScheduledFolderPicker = true
                } label: {
                    settingsRow(label: String(localized: "DataPrivacy.scheduledBackup.chooseFolder"))
                }
                .buttonStyle(.plain)

                Text(String(localized: "DataPrivacy.scheduledBackup.footer"))
                    .font(AppTheme.warmPaperMeta)
                    .foregroundStyle(AppTheme.settingsTextMuted)
                    .fixedSize(horizontal: false, vertical: true)
                    .listRowInsets(EdgeInsets())
            } header: {
                Text(String(localized: "DataPrivacy.scheduledBackup.section"))
                    .font(AppTheme.warmPaperMeta)
                    .foregroundStyle(AppTheme.settingsTextMuted)
                    .textCase(nil)
            }

            Section {
                Button {
                    showImportPicker = true
                } label: {
                    settingsRow(label: String(localized: "DataPrivacy.importExport.import.json"))
                }
                .buttonStyle(.plain)
                .disabled(isExportingData || isImportingData)

                NavigationLink {
                    BackupFolderImportFileListView { url in
                        pendingImportURL = url
                        showImportReview = true
                    }
                } label: {
                    settingsRow(label: String(localized: "DataPrivacy.importExport.import.fromBackupFolder"))
                }
                .disabled(scheduledFolderMissing)
            } header: {
                Text(String(localized: "DataPrivacy.importExport.section.import"))
                    .font(AppTheme.warmPaperMeta)
                    .foregroundStyle(AppTheme.settingsTextMuted)
                    .textCase(nil)
            }
        }
        .navigationTitle(String(localized: "DataPrivacy.importExport.title"))
        .listRowBackground(AppTheme.settingsPaper.opacity(0.9))
        .scrollContentBackground(.hidden)
        .background(AppTheme.settingsBackground)
        .onAppear {
            refreshHistory()
            scheduledInterval = ScheduledBackupPreferences.interval
        }
        .sheet(isPresented: $showImportReview) {
            importReviewSheet
        }
        .sheet(item: $exportFile) { file in
            ShareSheet(activityItems: [file.url])
        }
        .alert(String(localized: "Unable to export data"), isPresented: $showExportError) {
            Button(String(localized: "OK"), role: .cancel) {}
        } message: {
            Text(exportErrorMessage ?? String(localized: "Please try again."))
        }
        .fileImporter(
            isPresented: $showImportPicker,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                pendingImportURL = url
                importMode = .merge
                showImportReview = true
            case .failure:
                importErrorMessage = String(localized: "DataPrivacy.import.error.readFailed")
                showImportError = true
            }
        }
        .fileImporter(
            isPresented: $showScheduledFolderPicker,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                let accessed = url.startAccessingSecurityScopedResource()
                defer {
                    if accessed {
                        url.stopAccessingSecurityScopedResource()
                    }
                }
                do {
                    try ScheduledBackupPreferences.storeFolderBookmark(for: url)
                } catch {
                    scheduledFolderError = String(localized: "DataPrivacy.scheduledBackup.folderError")
                    showScheduledFolderError = true
                }
            case .failure:
                scheduledFolderError = String(localized: "DataPrivacy.scheduledBackup.folderError")
                showScheduledFolderError = true
            }
        }
        .alert(String(localized: "DataPrivacy.import.mergeConflict.title"), isPresented: $showMergeConflictResolution) {
            Button(String(localized: "DataPrivacy.import.mergeConflict.useBackup")) {
                runConflictResolution(.preferImported)
            }
            Button(String(localized: "DataPrivacy.import.mergeConflict.keepDevice")) {
                runConflictResolution(.preferLocal)
            }
            Button(String(localized: "Cancel"), role: .cancel) {}
        } message: {
            Text(
                String(
                    format: String(localized: "DataPrivacy.import.mergeConflict.message"),
                    mergeConflictDays.count
                )
            )
        }
        .alert(String(localized: "DataPrivacy.import.success.title"), isPresented: $showImportSuccess) {
            Button(String(localized: "OK"), role: .cancel) {
                importSuccessSummary = nil
            }
        } message: {
            if let summary = importSuccessSummary {
                Text(
                    String(
                        format: String(localized: "DataPrivacy.import.success.detail"),
                        summary.insertedCount,
                        summary.updatedCount
                    )
                )
            }
        }
        .alert(String(localized: "DataPrivacy.import.error.title"), isPresented: $showImportError) {
            Button(String(localized: "OK"), role: .cancel) {}
        } message: {
            Text(importErrorMessage ?? String(localized: "DataPrivacy.import.error.generic"))
        }
        .alert(String(localized: "DataPrivacy.scheduledBackup.folderError.title"), isPresented: $showScheduledFolderError) {
            Button(String(localized: "OK"), role: .cancel) {}
        } message: {
            Text(scheduledFolderError ?? String(localized: "Please try again."))
        }
        .overlay {
            if isExportingData {
                ProgressView(String(localized: "Exporting…"))
                    .font(AppTheme.warmPaperBody)
                    .padding(16)
                    .background(AppTheme.paper)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else if isImportingData {
                ProgressView(String(localized: "Importing…"))
                    .font(AppTheme.warmPaperBody)
                    .padding(16)
                    .background(AppTheme.paper)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private var scheduledFolderMissing: Bool {
        ScheduledBackupPreferences.folderBookmarkData == nil
    }

    @ViewBuilder
    private var importReviewSheet: some View {
        NavigationStack {
            List {
                Section {
                    Picker(String(localized: "DataPrivacy.import.mode.title"), selection: $importMode) {
                        Text(String(localized: "DataPrivacy.import.mode.merge")).tag(JournalImportMode.merge)
                        Text(String(localized: "DataPrivacy.import.mode.replace")).tag(JournalImportMode.replace)
                    }
                    .font(AppTheme.warmPaperBody)

                    Text(
                        importMode == .merge
                            ? String(localized: "DataPrivacy.import.mode.merge.detail")
                            : String(localized: "DataPrivacy.import.mode.replace.detail")
                    )
                    .font(AppTheme.warmPaperMeta)
                    .foregroundStyle(AppTheme.settingsTextMuted)
                    .fixedSize(horizontal: false, vertical: true)
                }

                Section {
                    Button(String(localized: "DataPrivacy.import.action")) {
                        performManualImport(conflictResolution: nil)
                    }
                    .font(AppTheme.warmPaperBody)
                    .disabled(pendingImportURL == nil || isImportingData)
                }
            }
            .navigationTitle(String(localized: "DataPrivacy.import.review.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) {
                        showImportReview = false
                        pendingImportURL = nil
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func refreshHistory() {
        exportHistory = BackupExportHistoryStore.load()
    }

    private func historyDetailLabel(for entry: BackupExportHistoryEntry) -> String {
        let kind: String
        switch entry.kind {
        case .manualShare:
            kind = String(localized: "DataPrivacy.importExport.history.kind.manual")
        case .scheduledFolder:
            kind = String(localized: "DataPrivacy.importExport.history.kind.scheduled")
        }
        let status: String
        if entry.success {
            status = String(localized: "DataPrivacy.importExport.history.status.success")
        } else {
            status = String(localized: "DataPrivacy.importExport.history.status.failed")
        }
        if let detail = entry.detail, !detail.isEmpty {
            return "\(kind) · \(status) · \(detail)"
        }
        return "\(kind) · \(status)"
    }
}

private extension ImportExportSettingsScreen {
    func settingsRow(label: String) -> some View {
        HStack(spacing: AppTheme.spacingRegular) {
            Text(label)
                .font(AppTheme.warmPaperBody)
                .foregroundStyle(AppTheme.settingsTextPrimary)
            Spacer(minLength: AppTheme.spacingRegular)
            Image(systemName: "chevron.right")
                .font(AppTheme.outfitSemiboldCaption)
                .foregroundStyle(AppTheme.settingsTextMuted)
        }
        .frame(minHeight: 44)
        .contentShape(Rectangle())
    }

    func exportJournalData() {
        guard !isExportingData else { return }
        isExportingData = true
        let container = modelContext.container
        let exportService = dataExportService

        Task {
            do {
                let fileURL = try await Task.detached(priority: .userInitiated) {
                    let backgroundContext = ModelContext(container)
                    return try exportService.exportArchiveFile(context: backgroundContext)
                }.value
                await MainActor.run {
                    BackupExportHistoryStore.record(
                        success: true,
                        kind: .manualShare,
                        detail: fileURL.lastPathComponent
                    )
                    refreshHistory()
                    exportFile = ShareableFile(url: fileURL)
                    isExportingData = false
                }
            } catch {
                await MainActor.run {
                    BackupExportHistoryStore.record(
                        success: false,
                        kind: .manualShare,
                        detail: nil
                    )
                    refreshHistory()
                    exportErrorMessage = String(localized: "Unable to export your Grace Notes data right now.")
                    showExportError = true
                    isExportingData = false
                }
            }
        }
    }

    func performManualImport(conflictResolution: JournalImportMergeConflictResolution?) {
        guard let url = pendingImportURL else { return }
        guard !isImportingData else { return }
        isImportingData = true
        let container = modelContext.container
        let importService = dataImportService
        let mode = importMode
        let calendar = Calendar.current

        Task {
            let accessed = url.startAccessingSecurityScopedResource()
            defer {
                if accessed {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            do {
                if let byteCount = JournalDataImportService.resolvedFileByteCount(at: url) {
                    try JournalDataImportService.checkImportPayloadByteCount(byteCount)
                }
                let fileData = try Data(contentsOf: url)
                let summary = try await Task.detached(priority: .userInitiated) {
                    let backgroundContext = ModelContext(container)
                    return try importService.importData(
                        fileData,
                        context: backgroundContext,
                        calendar: calendar,
                        mode: mode,
                        mergeConflictResolution: conflictResolution
                    )
                }.value
                await MainActor.run {
                    showImportReview = false
                    pendingImportURL = nil
                    importSuccessSummary = summary
                    showImportSuccess = true
                    isImportingData = false
                }
            } catch let error as JournalDataImportError {
                await MainActor.run {
                    if case .mergeConflicts(let days) = error {
                        mergeConflictDays = days
                        showMergeConflictResolution = true
                    } else {
                        importErrorMessage = importFailureMessage(for: error)
                        showImportError = true
                        showImportReview = false
                        pendingImportURL = nil
                    }
                    isImportingData = false
                }
            } catch {
                await MainActor.run {
                    importErrorMessage = importFailureMessage(for: error)
                    showImportError = true
                    showImportReview = false
                    pendingImportURL = nil
                    isImportingData = false
                }
            }
        }
    }

    func runConflictResolution(_ resolution: JournalImportMergeConflictResolution) {
        showMergeConflictResolution = false
        performManualImport(conflictResolution: resolution)
    }

    func importFailureMessage(for error: Error) -> String {
        if let importError = error as? JournalDataImportError {
            switch importError {
            case .invalidGraceNotesExport:
                return String(localized: "DataPrivacy.import.error.invalid")
            case .unsupportedSchemaVersion(let version):
                return String(
                    format: String(localized: "DataPrivacy.import.error.schema"),
                    version
                )
            case .fileTooLarge:
                return String(localized: "DataPrivacy.import.error.fileTooLarge")
            case .tooManyEntries:
                return String(localized: "DataPrivacy.import.error.tooManyEntries")
            case .mergeConflicts:
                return String(localized: "DataPrivacy.import.error.generic")
            }
        }
        return String(localized: "DataPrivacy.import.error.generic")
    }
}

private struct ShareableFile: Identifiable {
    let url: URL
    var id: String { url.absoluteString }
}

// MARK: - Backup folder file list

private struct BackupFolderImportFileListView: View {
    let onSelect: (URL) -> Void

    @State private var files: [URL] = []
    @State private var listError: String?

    var body: some View {
        Group {
            if let listError {
                Text(listError)
                    .font(AppTheme.warmPaperBody)
                    .foregroundStyle(AppTheme.settingsTextMuted)
                    .padding()
            } else if files.isEmpty {
                Text(String(localized: "DataPrivacy.importExport.backupFolder.empty"))
                    .font(AppTheme.warmPaperBody)
                    .foregroundStyle(AppTheme.settingsTextMuted)
                    .padding()
            } else {
                List(files, id: \.path) { url in
                    Button {
                        onSelect(url)
                    } label: {
                        Text(url.lastPathComponent)
                            .font(AppTheme.warmPaperBody)
                            .foregroundStyle(AppTheme.settingsTextPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                }
                .listRowBackground(AppTheme.settingsPaper.opacity(0.9))
                .scrollContentBackground(.hidden)
                .background(AppTheme.settingsBackground)
            }
        }
        .navigationTitle(String(localized: "DataPrivacy.importExport.backupFolder.title"))
        .background(AppTheme.settingsBackground)
        .task {
            load()
        }
    }

    private func load() {
        let folderURL: URL
        do {
            folderURL = try ScheduledBackupPreferences.resolveFolderURL()
        } catch {
            listError = String(localized: "DataPrivacy.importExport.backupFolder.unreachable")
            return
        }
        guard folderURL.startAccessingSecurityScopedResource() else {
            listError = String(localized: "DataPrivacy.importExport.backupFolder.unreachable")
            return
        }
        defer {
            folderURL.stopAccessingSecurityScopedResource()
        }
        do {
            files = try BackupFolderLibrary.listExportFiles(in: folderURL)
        } catch {
            listError = String(localized: "DataPrivacy.importExport.backupFolder.unreachable")
        }
    }
}
