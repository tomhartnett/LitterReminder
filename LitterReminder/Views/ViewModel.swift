//
//  ContentView+ViewModel.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 11/24/24.
//

import EventKit
import SwiftData
import SwiftUI

@Observable class ViewModel {
    var currentDate: Date

    var errorMessage: String?

    private var cleanings = [Cleaning]()

    var completedCleanings: [Cleaning] {
        cleanings.filter({ $0.isComplete }).sorted(by: {
            let completed1 = $0.completedDate ?? Date.distantPast
            let completed2 = $1.completedDate ?? Date.distantPast

            return completed1 > completed2
        })
    }

    var hasCompletedCleanings: Bool {
        !completedCleanings.isEmpty
    }

    var hasScheduledCleaning: Bool {
        scheduledCleaning != nil
    }

    var scheduledCleaning: Cleaning? {
        cleanings
            .filter({ !$0.isComplete })
            .sorted(by: { $0.scheduledDate < $1.scheduledDate })
            .first
    }

    private var modelContext: ModelContext

    private var eventStore: EKEventStore

    let dependencies: Dependencies

    init(
        dependencies: Dependencies,
        modelContext: ModelContext,
        currentDate: Date = .now
    ) {
        self.dependencies = dependencies
        self.modelContext = modelContext
        self.currentDate = currentDate
        self.eventStore = EKEventStore()
        fetchData()
    }

    func addCleaning(_ currentDate: Date = .now) {
        let scheduledDate = dependencies.schedulingService.nextCleaningDate()

        // TODO: handle error
        let reminderID = try? dependencies.reminderService.addReminder(scheduledDate)

        Task {
            // TODO: handle error
            let notificationID = try? await dependencies.notificationService.scheduleNotification(scheduledDate)

            await MainActor.run {
                let cleaning = Cleaning(
                    createdDate: currentDate,
                    scheduledDate: scheduledDate,
                    notificationID: notificationID,
                    reminderID: reminderID
                )

                modelContext.insert(cleaning)
                saveChanges()
                fetchData()
            }
        }
    }

    func delete(_ cleaning: Cleaning) {
        if let reminderID = cleaning.reminderID {
            // TODO: handle error
            try? dependencies.reminderService.deleteReminder(reminderID)
        }

        if let notificationID = cleaning.notificationID {
            dependencies.notificationService.deleteNotification(notificationID)
        }

        modelContext.delete(cleaning)
        saveChanges()
        fetchData()
    }

    func fetchData() {
        do {
            var descriptor = FetchDescriptor<Cleaning>(
                sortBy: [
                    SortDescriptor(\.createdDate, order: .reverse)
                ]
            )
            descriptor.fetchLimit = 20
            cleanings = try modelContext.fetch(descriptor)
        } catch {
            // TODO: handle error
        }
    }

    func markComplete(_ currentDate: Date = .now) {
        guard let scheduledCleaning else {
            return
        }

        if let reminderID = scheduledCleaning.reminderID {
            // TODO: handle error
            try? dependencies.reminderService.completeReminder(reminderID, completionDate: currentDate)
        }

        scheduledCleaning.completedDate = currentDate
        saveChanges()
        fetchData()
    }

    func requestAuthorization() {
        dependencies.reminderService.requestRemindersAccess()

        Task {
            // TODO: handle error
            try await dependencies.notificationService.requestAuthorization()
        }
    }

    func updateCurrentDate() {
        currentDate = .now
    }

    private func saveChanges() {
        do {
            try modelContext.save()
        } catch {
            print("Saved failed")
        }
    }
}
