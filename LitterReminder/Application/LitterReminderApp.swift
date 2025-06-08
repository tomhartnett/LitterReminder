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
    @Environment(\.scenePhase) private var scenePhase
    let container: ModelContainer
    let viewModel: ViewModel

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
            viewModel = ViewModel(dependencies: AppDependencies(), modelContext: container.mainContext)
        } catch {
            fatalError("Failed to create ModelContainer for Cleaning.")
        }
    }
}
