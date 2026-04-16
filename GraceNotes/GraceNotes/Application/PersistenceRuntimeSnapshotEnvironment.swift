import SwiftUI

/// Fallback when the app root does not inject `PersistenceController.runtimeSnapshot`.
/// Prefer local-only semantics so privacy and iCloud copy never assume CloudKit from a missing injection.
private struct PersistenceRuntimeSnapshotKey: EnvironmentKey {
    static let defaultValue = PersistenceRuntimeSnapshot.forInMemory(userRequestedCloudSync: false)
}

extension EnvironmentValues {
    var persistenceRuntimeSnapshot: PersistenceRuntimeSnapshot {
        get { self[PersistenceRuntimeSnapshotKey.self] }
        set { self[PersistenceRuntimeSnapshotKey.self] = newValue }
    }
}
