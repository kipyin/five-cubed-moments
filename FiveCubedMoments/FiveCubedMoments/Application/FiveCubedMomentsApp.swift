//
//  FiveCubedMomentsApp.swift
//  FiveCubedMoments
//
//  Created by Kip on 2026/3/15.
//

import SwiftUI
import SwiftData

@main
struct FiveCubedMomentsApp: App {
    private let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationStack {
                    JournalScreen()
                }
                .tabItem {
                    Label("Today", systemImage: "doc.text")
                }
                NavigationStack {
                    HistoryScreen()
                }
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
            }
        }
        .modelContainer(persistenceController.container)
    }
}
