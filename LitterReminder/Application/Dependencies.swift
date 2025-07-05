//
//  Dependencies.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 6/8/25.
//

import Foundation

protocol Dependencies {
    var notificationService: NotificationService { get }
    var reminderService: ReminderService { get }
    var schedulingService: SchedulingService { get }
    var cleaningService: CleaningService { get }
    var addCleaningUseCase: AddCleaningUseCase { get }
    var markCompleteUseCase: MarkCompleteUseCase { get }
}

final class AppDependencies: Dependencies {
    let cleaningService: CleaningService
    let notificationService: NotificationService
    let reminderService: ReminderService
    let schedulingService: SchedulingService
    let addCleaningUseCase: AddCleaningUseCase
    let markCompleteUseCase: MarkCompleteUseCase

    init(
        cleaningService: CleaningService,
        notificationService: NotificationService,
        reminderService: ReminderService,
        schedulingService: SchedulingService
    ) {
        self.cleaningService = cleaningService
        self.notificationService = notificationService
        self.reminderService = reminderService
        self.schedulingService = schedulingService

        addCleaningUseCase = DefaultAddCleaningUseCase(
            cleaningService: cleaningService,
            reminderService: reminderService,
            notificationService: notificationService,
            schedulingService: schedulingService
        )

        markCompleteUseCase = DefaultMarkCompleteUseCase(
            cleaningService: cleaningService,
            reminderService: reminderService,
            notificationService: notificationService,
            schedulingService: schedulingService
        )
    }
}

final class PreviewDependencies: Dependencies {
    let notificationService: NotificationService = PreviewNotificationService()
    let reminderService: ReminderService = PreviewReminderService()
    let schedulingService: SchedulingService = PreviewSchedulingService()
    let cleaningService: CleaningService = PreviewCleaningService()
    let addCleaningUseCase: AddCleaningUseCase = PreviewAddCleaningUseCase()
    let markCompleteUseCase: MarkCompleteUseCase = PreviewMarkCompleteUseCase()
}
