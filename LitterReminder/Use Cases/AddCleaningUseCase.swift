//
//  AddCleaningUseCase.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 6/23/25.
//

import Foundation

protocol AddCleaningUseCase {
    func execute(currentDate: Date, scheduledDate: Date) async throws
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

    func execute(currentDate: Date, scheduledDate: Date) async throws {
        // TODO: pass cleaningID to notificationService and save it on the notification
        let cleaningID = try cleaningService.addCleaning(
            currentDate: currentDate,
            scheduledDate: scheduledDate,
            notificationID: nil,
            reminderID: nil
        )
    }
}
