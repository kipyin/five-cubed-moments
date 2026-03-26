import XCTest
@testable import GraceNotes

final class PersistenceRuntimeSnapshotTests: XCTestCase {
    func test_forInMemory_neverCloudOrFallback() {
        let enabledSnapshot = PersistenceRuntimeSnapshot.forInMemory(userRequestedCloudSync: true)
        XCTAssertTrue(enabledSnapshot.userRequestedCloudSync)
        XCTAssertFalse(enabledSnapshot.storeUsesCloudKit)
        XCTAssertFalse(enabledSnapshot.startupUsedCloudKitFallback)

        let disabledSnapshot = PersistenceRuntimeSnapshot.forInMemory(userRequestedCloudSync: false)
        XCTAssertFalse(disabledSnapshot.userRequestedCloudSync)
        XCTAssertFalse(disabledSnapshot.storeUsesCloudKit)
        XCTAssertFalse(disabledSnapshot.startupUsedCloudKitFallback)
    }

    func test_forDiskLaunch_cloudSuccess() {
        let snapshot = PersistenceRuntimeSnapshot.forDiskLaunch(
            userRequestedCloudSync: true,
            storeUsesCloudKit: true,
            startupUsedCloudKitFallback: false
        )
        XCTAssertTrue(snapshot.userRequestedCloudSync)
        XCTAssertTrue(snapshot.storeUsesCloudKit)
        XCTAssertFalse(snapshot.startupUsedCloudKitFallback)
    }

    func test_forDiskLaunch_localByChoice() {
        let snapshot = PersistenceRuntimeSnapshot.forDiskLaunch(
            userRequestedCloudSync: false,
            storeUsesCloudKit: false,
            startupUsedCloudKitFallback: false
        )
        XCTAssertFalse(snapshot.userRequestedCloudSync)
        XCTAssertFalse(snapshot.storeUsesCloudKit)
        XCTAssertFalse(snapshot.startupUsedCloudKitFallback)
    }

    func test_forDiskLaunch_silentFallback() {
        let snapshot = PersistenceRuntimeSnapshot.forDiskLaunch(
            userRequestedCloudSync: true,
            storeUsesCloudKit: false,
            startupUsedCloudKitFallback: true
        )
        XCTAssertTrue(snapshot.userRequestedCloudSync)
        XCTAssertFalse(snapshot.storeUsesCloudKit)
        XCTAssertTrue(snapshot.startupUsedCloudKitFallback)
    }

    func test_makeInMemoryForTesting_matchesFactory() throws {
        let controller = try PersistenceController.makeInMemoryForTesting()
        let expected = PersistenceRuntimeSnapshot.forInMemory(userRequestedCloudSync: false)
        XCTAssertEqual(controller.runtimeSnapshot, expected)
    }
}
