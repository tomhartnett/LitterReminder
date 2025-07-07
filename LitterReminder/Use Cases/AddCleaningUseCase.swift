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
    private let cleaningService: CleaningService
    private let reminderService: ReminderService
    private let notificationService: NotificationService
    private let schedulingService: SchedulingService

    init(
        cleaningService: CleaningService,
        reminderService: ReminderService,
        notificationService: NotificationService,
        schedulingService: SchedulingService
    ) {
        self.cleaningService = cleaningService
        self.reminderService = reminderService
        self.notificationService = notificationService
        self.schedulingService = schedulingService
    }

    func execute(currentDate: Date) async throws {
        let scheduledDate = schedulingService.nextCleaningDate()
        let notificationID = try await notificationService.scheduleNotification(scheduledDate)
        let reminderID = try reminderService.addReminder(scheduledDate)

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
