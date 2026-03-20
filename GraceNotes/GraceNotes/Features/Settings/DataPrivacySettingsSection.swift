import SwiftUI

struct DataPrivacySettingsSection: View {
    @Binding var isICloudSyncEnabled: Bool
    @ObservedObject var iCloudAccountState: ICloudAccountStatusModel
    let persistenceRuntimeSnapshot: PersistenceRuntimeSnapshot
    let isExportingData: Bool
    let isImportingData: Bool
    let onExport: () -> Void
    let onImport: () -> Void
    let openSystemSettings: () -> Void

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: AppTheme.spacingRegular) {
                storageSummaryBlock

                if let attentionMessage {
                    attentionBlock(message: attentionMessage)
                }

                if shouldShowICloudSyncToggle {
                    Toggle(String(localized: "iCloud sync"), isOn: $isICloudSyncEnabled)
                        .font(AppTheme.warmPaperBody)
                        .foregroundStyle(AppTheme.settingsTextPrimary)
                        .tint(AppTheme.accent)
                        .frame(minHeight: 44)
                }

                backupBlock
            }
            .padding(.vertical, AppTheme.spacingTight / 2)
        } header: {
            Text(String(localized: "Data & Privacy"))
                .font(AppTheme.warmPaperHeader)
                .foregroundStyle(AppTheme.settingsTextPrimary)
        } footer: {
            VStack(alignment: .leading, spacing: AppTheme.spacingTight) {
                Text(String(localized: "DataPrivacy.footer.exportAndImport"))
                Text(String(localized: "DataPrivacy.footer.iCloudNotFullBackup"))
            }
            .font(AppTheme.warmPaperBody)
            .foregroundStyle(AppTheme.settingsTextMuted)
        }
    }
}

private extension DataPrivacySettingsSection {
    var preferenceMatchesEffectiveStore: Bool {
        isICloudSyncEnabled == persistenceRuntimeSnapshot.storeUsesCloudKit
    }

    var shouldOfferICloudSettingsLink: Bool {
        guard let bucket = iCloudAccountState.displayedBucket else { return false }
        switch bucket {
        case .noAccount, .restricted:
            return true
        case .available, .temporarilyUnavailable, .couldNotDetermine:
            return false
        }
    }

    /// `nil` bucket (still checking) keeps the toggle visible to avoid an empty first paint.
    var shouldShowICloudSyncToggle: Bool {
        iCloudAccountState.displayedBucket?.showsICloudSyncToggle ?? true
    }

    /// Journal data is on the CloudKit-backed store (not the startup local fallback).
    private var isJournalOnCloudKitStore: Bool {
        persistenceRuntimeSnapshot.storeUsesCloudKit && !persistenceRuntimeSnapshot.startupUsedCloudKitFallback
    }

    var primaryStorageBody: String {
        if persistenceRuntimeSnapshot.startupUsedCloudKitFallback {
            return String(localized: "DataPrivacy.storage.fallbackLocal")
        }
        return String(localized: "DataPrivacy.storage.localOnly")
    }

    var attentionMessage: String? {
        if let bucket = iCloudAccountState.displayedBucket {
            switch bucket {
            case .noAccount:
                return String(localized: "DataPrivacy.attention.noAccount.summary")
            case .restricted:
                return String(localized: "DataPrivacy.attention.restricted.summary")
            case .temporarilyUnavailable:
                if !preferenceMatchesEffectiveStore {
                    return String(localized: "DataPrivacy.attention.tempUnavailableMismatch.summary")
                }
                return String(localized: "DataPrivacy.attention.tempUnavailable")
            case .couldNotDetermine:
                if !preferenceMatchesEffectiveStore {
                    return String(localized: "DataPrivacy.attention.unknownMismatch.summary")
                }
                return String(localized: "DataPrivacy.attention.unknown")
            case .available:
                break
            }
        }

        if persistenceRuntimeSnapshot.startupUsedCloudKitFallback, isICloudSyncEnabled {
            return String(localized: "DataPrivacy.attention.retryICloudAfterRelaunch.summary")
        }

        if !preferenceMatchesEffectiveStore {
            if shouldShowICloudSyncToggle {
                return String(localized: "DataPrivacy.attention.toggleChangedRelaunch.summary")
            }
            return String(localized: "DataPrivacy.attention.preferenceMismatchRelaunch.summary")
        }

        return nil
    }

    var storageSummaryBlock: some View {
        Group {
            if isJournalOnCloudKitStore {
                storageHeadingOnlyBlock
            } else {
                storageHeadingWithLocalDescriptionBlock
            }
        }
    }

    /// No Storage body for CloudKit store; status copy is in `attentionBlock`.
    private var storageHeadingOnlyBlock: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingTight / 2) {
            Text(String(localized: "DataPrivacy.storage.heading"))
                .font(AppTheme.warmPaperMeta)
                .foregroundStyle(AppTheme.settingsTextMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(String(localized: "DataPrivacy.a11y.storage.cloudActive"))
    }

    private var storageHeadingWithLocalDescriptionBlock: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingTight / 2) {
            Text(String(localized: "DataPrivacy.storage.heading"))
                .font(AppTheme.warmPaperMeta)
                .foregroundStyle(AppTheme.settingsTextMuted)
            Text(primaryStorageBody)
                .font(AppTheme.warmPaperBody)
                .foregroundStyle(AppTheme.settingsTextPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(String(localized: "DataPrivacy.a11y.storage"))
    }

    func attentionBlock(message: String) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingTight) {
            Text(message)
                .font(AppTheme.warmPaperBody)
                .foregroundStyle(AppTheme.settingsTextPrimary)
                .fixedSize(horizontal: false, vertical: true)

            if shouldOfferICloudSettingsLink {
                SettingsOpenSystemSettingsButton(
                    action: openSystemSettings,
                    accessibilityHint: String(
                        localized:
                            "Opens iOS Settings where you can sign in to iCloud or review restrictions."
                    ),
                    emphasis: .prominent
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(String(localized: "DataPrivacy.a11y.nextSteps"))
    }

    var backupBlock: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingTight / 2) {
            Text(String(localized: "DataPrivacy.backup.heading"))
                .font(AppTheme.warmPaperMeta)
                .foregroundStyle(AppTheme.settingsTextMuted)
            Text(String(localized: "DataPrivacy.backup.subtitle"))
                .font(AppTheme.warmPaperMeta)
                .foregroundStyle(AppTheme.settingsTextMuted)
                .fixedSize(horizontal: false, vertical: true)
            Button(action: onExport) {
                Text(String(localized: "Export Grace Notes data (JSON)"))
                    .underline()
            }
            .font(AppTheme.warmPaperBody)
            .foregroundStyle(AppTheme.settingsTextMuted)
            .buttonStyle(.plain)
            .disabled(isExportingData || isImportingData)
            .frame(minHeight: 44, alignment: .leading)

            Button(action: onImport) {
                Text(String(localized: "Import Grace Notes data (JSON)"))
                    .underline()
            }
            .font(AppTheme.warmPaperBody)
            .foregroundStyle(AppTheme.settingsTextMuted)
            .buttonStyle(.plain)
            .disabled(isExportingData || isImportingData)
            .frame(minHeight: 44, alignment: .leading)
        }
        .padding(.top, AppTheme.spacingRegular)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(String(localized: "DataPrivacy.a11y.backup"))
    }
}
