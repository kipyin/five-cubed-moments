import SwiftUI
import XCTest
@testable import GraceNotes

@MainActor
final class JournalScreenChipHandlingEdgeCaseTests: XCTestCase {
    func test_performChipTap_whenUpdateFails_doesNotSwitchToTappedChip() {
        var input = "Edited draft"
        var editingIndex: Int? = 0
        var isTransitioning = false
        var summarizedIndex: Int?
        let operations = ChipSectionOperations(
            updateImmediate: { _, _ in nil },
            addImmediate: { _ in 99 },
            remove: { _ in false },
            fullText: { index in
                index == 0 ? "Stored" : "Other chip"
            },
            count: 2,
            summarizeAndUpdateChip: { summarizedIndex = $0 }
        )

        let handled = JournalScreenChipHandling.performChipTap(
            tapIndex: 1,
            input: Binding(get: { input }, set: { input = $0 }),
            editingIndex: Binding(get: { editingIndex }, set: { editingIndex = $0 }),
            operations: operations,
            isTransitioning: Binding(get: { isTransitioning }, set: { isTransitioning = $0 })
        )

        XCTAssertTrue(handled)
        XCTAssertEqual(input, "Edited draft")
        XCTAssertEqual(editingIndex, 0)
        XCTAssertNil(summarizedIndex)
    }

    func test_submitChipSection_whenEditingWhitespaceOnly_deletesAndClearsDraft() {
        var input = "   \n"
        var editingIndex: Int? = 1
        var isTransitioning = false
        var didUpdate = false
        var didRemove = false
        let operations = ChipSectionOperations(
            updateImmediate: { _, _ in
                didUpdate = true
                return 0
            },
            addImmediate: { _ in 0 },
            remove: { index in
                didRemove = true
                return index == 1
            },
            fullText: { _ in nil },
            count: 0,
            summarizeAndUpdateChip: { _ in }
        )

        let didSubmit = JournalScreenChipHandling.submitChipSection(
            editingIndex: Binding(get: { editingIndex }, set: { editingIndex = $0 }),
            input: Binding(get: { input }, set: { input = $0 }),
            operations: operations,
            isTransitioning: Binding(get: { isTransitioning }, set: { isTransitioning = $0 })
        )

        XCTAssertTrue(didSubmit)
        XCTAssertEqual(input, "")
        XCTAssertNil(editingIndex)
        XCTAssertFalse(didUpdate)
        XCTAssertTrue(didRemove)
        XCTAssertFalse(isTransitioning)
    }

    func test_submitChipSection_whenAddingWhitespaceOnly_returnsFalseWithoutMutating() {
        var input = "   \n"
        var editingIndex: Int?
        var isTransitioning = false
        var didUpdate = false
        var didAdd = false
        var didRemove = false
        let operations = ChipSectionOperations(
            updateImmediate: { _, _ in
                didUpdate = true
                return 0
            },
            addImmediate: { _ in
                didAdd = true
                return 0
            },
            remove: { _ in
                didRemove = true
                return true
            },
            fullText: { _ in nil },
            count: 0,
            summarizeAndUpdateChip: { _ in }
        )

        let didSubmit = JournalScreenChipHandling.submitChipSection(
            editingIndex: Binding(get: { editingIndex }, set: { editingIndex = $0 }),
            input: Binding(get: { input }, set: { input = $0 }),
            operations: operations,
            isTransitioning: Binding(get: { isTransitioning }, set: { isTransitioning = $0 })
        )

        XCTAssertFalse(didSubmit)
        XCTAssertEqual(input, "   \n")
        XCTAssertNil(editingIndex)
        XCTAssertFalse(didUpdate)
        XCTAssertFalse(didAdd)
        XCTAssertFalse(didRemove)
        XCTAssertFalse(isTransitioning)
    }

    func test_submitChipSection_whenEditingAndUpdateSucceeds_clearsAndSummarizes() {
        var input = "Revision"
        var editingIndex: Int? = 2
        var isTransitioning = false
        var summarizedIndex: Int?
        let operations = ChipSectionOperations(
            updateImmediate: { index, _ in index },
            addImmediate: { _ in nil },
            remove: { _ in false },
            fullText: { _ in nil },
            count: 3,
            summarizeAndUpdateChip: { summarizedIndex = $0 }
        )

        let didSubmit = JournalScreenChipHandling.submitChipSection(
            editingIndex: Binding(get: { editingIndex }, set: { editingIndex = $0 }),
            input: Binding(get: { input }, set: { input = $0 }),
            operations: operations,
            isTransitioning: Binding(get: { isTransitioning }, set: { isTransitioning = $0 })
        )

        XCTAssertTrue(didSubmit)
        XCTAssertEqual(input, "")
        XCTAssertNil(editingIndex)
        XCTAssertEqual(summarizedIndex, 2)
    }

    func test_performDelete_whenDeletingEditedChip_clearsDraft() {
        var input = "Draft"
        var editingIndex: Int? = 2

        JournalScreenChipHandling.performDelete(
            index: 2,
            remove: { _ in true },
            input: Binding(get: { input }, set: { input = $0 }),
            editingIndex: Binding(get: { editingIndex }, set: { editingIndex = $0 })
        )

        XCTAssertNil(editingIndex)
        XCTAssertEqual(input, "")
    }

    func test_performMove_whenMoveFails_leavesEditingIndex() {
        var editingIndex: Int? = 2
        var didCallMove = false

        JournalScreenChipHandling.performMove(
            from: 0,
            to: 1,
            move: { _, _ in
                didCallMove = true
                return false
            },
            editingIndex: Binding(get: { editingIndex }, set: { editingIndex = $0 })
        )

        XCTAssertTrue(didCallMove)
        XCTAssertEqual(editingIndex, 2)
    }

    func test_performMove_whenNotEditing_leavesNilEditingIndex() {
        var editingIndex: Int?
        var didCallMove = false

        JournalScreenChipHandling.performMove(
            from: 0,
            to: 1,
            move: { _, _ in
                didCallMove = true
                return true
            },
            editingIndex: Binding(get: { editingIndex }, set: { editingIndex = $0 })
        )

        XCTAssertTrue(didCallMove)
        XCTAssertNil(editingIndex)
    }

    func test_handleAddChipTap_whileTransitioning_returnsFalseWithoutMutating() {
        var input = "Draft"
        var editingIndex: Int? = nil
        var isTransitioning = true
        var didAdd = false
        let operations = ChipSectionOperations(
            updateImmediate: { _, _ in 0 },
            addImmediate: { _ in
                didAdd = true
                return 0
            },
            remove: { _ in false },
            fullText: { _ in nil },
            count: 0,
            summarizeAndUpdateChip: { _ in }
        )

        let handled = JournalScreenChipHandling.handleAddChipTap(
            input: Binding(get: { input }, set: { input = $0 }),
            editingIndex: Binding(get: { editingIndex }, set: { editingIndex = $0 }),
            operations: operations,
            isTransitioning: Binding(get: { isTransitioning }, set: { isTransitioning = $0 })
        )

        XCTAssertFalse(handled)
        XCTAssertEqual(input, "Draft")
        XCTAssertNil(editingIndex)
        XCTAssertFalse(didAdd)
    }

    func test_performChipTap_whenNotEditingButDraftPresent_addsThenOpensTappedChip() {
        var input = "New draft line"
        var editingIndex: Int?
        var isTransitioning = false
        var addedIndex: Int?
        let operations = ChipSectionOperations(
            updateImmediate: { _, _ in nil },
            addImmediate: { text in
                addedIndex = 0
                XCTAssertEqual(text, "New draft line")
                return 0
            },
            remove: { _ in false },
            fullText: { index in
                index == 1 ? "Second saved" : "First saved"
            },
            count: 2,
            summarizeAndUpdateChip: { _ in }
        )

        let handled = JournalScreenChipHandling.performChipTap(
            tapIndex: 1,
            input: Binding(get: { input }, set: { input = $0 }),
            editingIndex: Binding(get: { editingIndex }, set: { editingIndex = $0 }),
            operations: operations,
            isTransitioning: Binding(get: { isTransitioning }, set: { isTransitioning = $0 })
        )

        XCTAssertTrue(handled)
        XCTAssertEqual(editingIndex, 1)
        XCTAssertEqual(input, "Second saved")
        XCTAssertEqual(addedIndex, 0)
    }
}
