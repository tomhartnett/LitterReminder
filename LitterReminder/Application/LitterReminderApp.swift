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
    let container: ModelContainer

    var body: some Scene {
        WindowGroup {
            ContentView(modelContext: container.mainContext)
        }
        .modelContainer(container)
    }

    init() {
        do {
            container = try ModelContainer(for: Cleaning.self)
        } catch {
            fatalError("Failed to create ModelContainer for Cleaning.")
        }
    }
}
