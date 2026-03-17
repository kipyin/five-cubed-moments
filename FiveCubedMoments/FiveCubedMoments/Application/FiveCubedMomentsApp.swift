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
    private let persistenceController: PersistenceController
    @State private var hasRunDeferredStartupTasks = false

    init() {
        let startupTrace = PerformanceTrace.begin("App.init")
        persistenceController = PersistenceController.shared
        PerformanceTrace.end("App.init", startedAt: startupTrace)
    }

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
                NavigationStack {
                    SettingsScreen()
                }
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
            }
            .preferredColorScheme(.light)
            .background(AppTheme.background)
            .toolbarBackground(AppTheme.background, for: .tabBar)
            .tint(AppTheme.accent)
            .task {
                await runDeferredStartupTasksIfNeeded()
            }
        }
        .modelContainer(persistenceController.container)
    }

    @MainActor
    private func runDeferredStartupTasksIfNeeded() async {
        guard !hasRunDeferredStartupTasks else { return }
        hasRunDeferredStartupTasks = true

#if USE_DEMO_DATABASE
        guard PersistenceController.isDemoDatabaseEnabled else { return }
        PerformanceTrace.instant("Starting deferred demo seeding")
        await Task.yield()
        let context = ModelContext(persistenceController.container)
        DemoDataSeeder.seedIfNeeded(context: context)
#endif
    }
}
