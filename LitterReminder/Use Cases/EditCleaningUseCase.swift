//
//  EditCleaningUseCase.swift
//  LitterReminder
//

import Foundation

protocol EditCleaningUseCase {
    func execute(_ cleaning: Cleaning, scheduledDate: Date, completedDate: Date?) async throws
}

final class DefaultEditCleaningUseCase: EditCleaningUseCase {
    private let appSettings: AppSettings
    private let cleaningService: CleaningService
    private let reminderService: ReminderService
    private let notificationService: NotificationService

    init(
        appSettings: AppSettings,
        cleaningService: CleaningService,
        reminderService: ReminderService,
        notificationService: NotificationService
    ) {
        self.appSettings = appSettings
        self.cleaningService = cleaningService
        self.reminderService = reminderService
        self.notificationService = notificationService
    }

    @MainActor
    func execute(_ cleaning: Cleaning, scheduledDate: Date, completedDate: Date?) async throws {
        let scheduledDateChanged = cleaning.scheduledDate != scheduledDate
        let completedDateChanged = cleaning.completedDate != completedDate

        guard scheduledDateChanged || completedDateChanged else {
            return
        }

        cleaning.scheduledDate = scheduledDate
        cleaning.completedDate = completedDate

        if cleaning.isComplete {
            if completedDateChanged {
                // Keep the completed reminder's completion date in sync.
                try reminderService.completeReminder(cleaning.reminderID, completionDate: completedDate)
            }
        } else if scheduledDateChanged {
            try await reschedule(cleaning, to: scheduledDate)
        }

        try cleaningService.updateCleaning(cleaning)
    }

    /// Replaces the pending notification and reminder for a not-yet-completed cleaning.
    @MainActor
    private func reschedule(_ cleaning: Cleaning, to date: Date) async throws {
        notificationService.deleteNotification(cleaning.notificationID)
        cleaning.notificationID = nil

        try reminderService.deleteReminder(cleaning.reminderID)
        cleaning.reminderID = nil

        if appSettings.isNotificationsEnabled {
            cleaning.notificationID = try await notificationService.scheduleNotification(date)
        }

        if appSettings.isRemindersEnabled {
            cleaning.reminderID = try reminderService.addReminder(date, title: appSettings.resolvedReminderTitle)
        }
    }
}

final class PreviewEditCleaningUseCase: EditCleaningUseCase {
    func execute(_ cleaning: Cleaning, scheduledDate: Date, completedDate: Date?) async throws {}
}
