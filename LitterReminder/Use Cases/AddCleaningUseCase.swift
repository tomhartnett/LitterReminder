//
//  AddCleaningUseCase.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 6/23/25.
//

import Foundation

protocol AddCleaningUseCase {
    func execute(currentDate: Date) async throws
}

final class DefaultAddCleaningUseCase: AddCleaningUseCase {
    private let appSettings: AppSettings
    private let cleaningService: CleaningService
    private let reminderService: ReminderService
    private let notificationService: NotificationService
    private let schedulingService: SchedulingService

    init(
        appSettings: AppSettings,
        cleaningService: CleaningService,
        reminderService: ReminderService,
        notificationService: NotificationService,
        schedulingService: SchedulingService
    ) {
        self.appSettings = appSettings
        self.cleaningService = cleaningService
        self.reminderService = reminderService
        self.notificationService = notificationService
        self.schedulingService = schedulingService
    }

    @MainActor
    func execute(currentDate: Date) async throws {
        let scheduledDate = schedulingService.nextCleaningDate()

        var notificationID: String?
        if appSettings.isNotificationsEnabled {
            notificationID = try await notificationService.scheduleNotification(scheduledDate)
        }

        var reminderID: String?
        if appSettings.isRemindersEnabled {
            reminderID = try reminderService.addReminder(scheduledDate)
        }

        try cleaningService.addCleaning(
            currentDate: currentDate,
            scheduledDate: scheduledDate,
            notificationID: notificationID,
            reminderID: reminderID
        )
    }
}

final class PreviewAddCleaningUseCase: AddCleaningUseCase {
    func execute(currentDate: Date) async throws {}
}
