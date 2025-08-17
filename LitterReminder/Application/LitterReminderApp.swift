//
//  LitterReminderApp.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 11/17/24.
//

import SwiftData
import SwiftUI

@main
struct LitterReminderApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate

    @Environment(\.scenePhase) private var scenePhase

    @State var appSettings: AppSettings

    let container: ModelContainer

    let homeViewModel: HomeViewModel

    let dependencies: AppDependencies

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appSettings)
                .environment(homeViewModel)
                .environment(\.dependencies, dependencies)
        }
        .modelContainer(container)
        .onChange(of: scenePhase) { _, newValue in
            if newValue == .active {
                homeViewModel.fetchData()
                homeViewModel.updateCurrentDate()
            }
        }
    }

    init() {
        do {
            container = try ModelContainer(
                for: Cleaning.self,
                migrationPlan: CleaningMigrationPlan.self
            )

            let appSettings = AppSettings()
            _appSettings = State(wrappedValue: appSettings)

            dependencies = AppDependencies(
                appSettings: appSettings,
                cleaningService: DefaultCleaningService(modelContext: container.mainContext),
                notificationService: DefaultNotificationService(),
                reminderService: DefaultReminderService(),
                schedulingService: DefaultSchedulingService(appSettings: appSettings)
            )

            homeViewModel = HomeViewModel(dependencies: dependencies)

            appDelegate.dependencies = dependencies
            appDelegate.modelContainer = container

        } catch {
            fatalError("Failed to create dependencies or ViewModel.")
        }
    }
}
