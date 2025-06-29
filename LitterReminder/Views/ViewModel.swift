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

    private var eventStore: EKEventStore

    let dependencies: Dependencies

    init(
        dependencies: Dependencies,
        currentDate: Date = .now
    ) {
        self.dependencies = dependencies
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
                do {
                    try dependencies.cleaningService.addCleaning(
                        currentDate: currentDate,
                        scheduledDate: scheduledDate,
                        notificationID: notificationID,
                        reminderID: reminderID
                    )
                    fetchData()
                } catch {
                    // TODO: handle error
                }
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

        do {
            try dependencies.cleaningService.deleteCleaning(cleaning)
            fetchData()
        } catch {
            // TODO: handle error
        }
    }

    func fetchData() {
        do {
            cleanings = try dependencies.cleaningService.fetchAllCleanings(limit: 20)
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

        do {
            try dependencies.cleaningService.markComplete(scheduledCleaning, currentDate: currentDate)
            fetchData()
        } catch {
            // TODO: handle error
        }
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
}
