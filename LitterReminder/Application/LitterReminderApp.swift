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
    let container: ModelContainer
    let viewModel: ViewModel
    let dependencies: Dependencies

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(viewModel)
        }
        .modelContainer(container)
        .onChange(of: scenePhase) { _, newValue in
            if newValue == .active {
                viewModel.fetchData()
                viewModel.updateCurrentDate()
                viewModel.requestAuthorization()
            }
        }
    }

    init() {
        do {
            container = try ModelContainer(for: Cleaning.self)
            dependencies = AppDependencies()
            viewModel = ViewModel(dependencies: dependencies, modelContext: container.mainContext)
            appDelegate.dependencies = dependencies
            appDelegate.modelContainer = container
        } catch {
            fatalError("Failed to create ModelContainer for Cleaning.")
        }
    }
}
