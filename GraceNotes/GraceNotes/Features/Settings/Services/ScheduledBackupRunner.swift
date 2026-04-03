import Foundation
import SwiftData

enum ScheduledBackupRunner {
    /// Writes a JSON export into the user’s appointed folder when the schedule says it is time.
    @MainActor
    static func runIfDue(modelContainer: ModelContainer) async {
        let interval = ScheduledBackupPreferences.interval
        guard interval != .off else { return }
        guard ScheduledBackupPreferences.isDue() else { return }

        let folderURL: URL
        do {
            folderURL = try ScheduledBackupPreferences.resolveFolderURL()
        } catch {
            return
        }

        guard folderURL.startAccessingSecurityScopedResource() else {
            return
        }
        defer {
            folderURL.stopAccessingSecurityScopedResource()
        }

        do {
            let exportService = JournalDataExportService()
            let backgroundContext = ModelContext(modelContainer)
            let tempFile = try exportService.exportArchiveFile(context: backgroundContext)
            defer {
                try? FileManager.default.removeItem(at: tempFile)
            }

            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .gregorian)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyyMMdd-HHmmss"
            let name = "grace-notes-scheduled-\(formatter.string(from: .now)).json"
            let destination = folderURL.appendingPathComponent(name, isDirectory: false)

            if FileManager.default.fileExists(atPath: destination.path) {
                try FileManager.default.removeItem(at: destination)
            }
            try FileManager.default.copyItem(at: tempFile, to: destination)

            ScheduledBackupPreferences.lastRunAt = Date()
            BackupExportHistoryStore.record(
                success: true,
                kind: .scheduledFolder,
                detail: name
            )
        } catch {
            BackupExportHistoryStore.record(
                success: false,
                kind: .scheduledFolder,
                detail: String(localized: "DataPrivacy.scheduledBackup.failureDetail")
            )
        }
    }
}

enum BackupFolderLibrary {
    static func listExportFiles(in folder: URL) throws -> [URL] {
        let urls = try FileManager.default.contentsOfDirectory(
            at: folder,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: [.skipsHiddenFiles]
        )
        let json = urls.filter { $0.pathExtension.lowercased() == "json" }
        return json.sorted { lhs, rhs in
            let l = (try? lhs.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
            let r = (try? rhs.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
            return l > r
        }
    }
}
