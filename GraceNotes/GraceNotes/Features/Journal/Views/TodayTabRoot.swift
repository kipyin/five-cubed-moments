import SwiftUI

/// Shell for the Today tab’s navigation. When Bloom (Summer) appearance is on, paper and leaves are layered
/// in ``GraceNotesApp`` above the whole ``TabView`` so they stay visible behind system chrome.
struct TodayTabRoot: View {
    var body: some View {
        NavigationStack {
            JournalScreen()
        }
    }
}
