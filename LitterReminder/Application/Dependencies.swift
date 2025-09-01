//
//  Dependencies.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 6/8/25.
//

import Foundation

protocol Dependencies: Observable {
    var appSettings: AppSettings { get }
    var notificationService: NotificationService { get }
    var reminderService: ReminderService { get }
    var schedulingService: SchedulingService { get }
    var cleaningService: CleaningService { get }
    var addCleaningUseCase: AddCleaningUseCase { get }
    var deleteUseCase: DeleteUseCase { get }
    var markCompleteUseCase: MarkCompleteUseCase { get }
}

@Observable
final class AppDependencies: Dependencies {
    let appSettings: AppSettings
    let cleaningService: CleaningService
    let notificationService: NotificationService
    let reminderService: ReminderService
    let schedulingService: SchedulingService
    let addCleaningUseCase: AddCleaningUseCase
    let deleteUseCase: DeleteUseCase
    let markCompleteUseCase: MarkCompleteUseCase

    init(
        appSettings: AppSettings,
        cleaningService: CleaningService,
        notificationService: NotificationService,
        reminderService: ReminderService,
        schedulingService: SchedulingService
    ) {
        self.appSettings = appSettings
        self.cleaningService = cleaningService
        self.notificationService = notificationService
        self.reminderService = reminderService
        self.schedulingService = schedulingService

        addCleaningUseCase = DefaultAddCleaningUseCase(
            appSettings: appSettings,
            cleaningService: cleaningService,
            reminderService: reminderService,
            notificationService: notificationService,
            schedulingService: schedulingService
        )

        deleteUseCase = DefaultDeleteUseCase(
            cleaningService: cleaningService,
            reminderService: reminderService,
            notificationService: notificationService
        )

        markCompleteUseCase = DefaultMarkCompleteUseCase(
            appSettings: appSettings,
            cleaningService: cleaningService,
            reminderService: reminderService,
            notificationService: notificationService,
            schedulingService: schedulingService
        )

        let isRemindersPermissionGranted = reminderService.isPermissionGranted
        if !isRemindersPermissionGranted {
            appSettings.isRemindersEnabled = false
        }

        Task { @MainActor in
            let isNotificationsPermissionGranted = await notificationService.isPermissionGranted
            if !isNotificationsPermissionGranted {
                appSettings.isNotificationsEnabled = false
            }
        }
    }
}

@Observable
final class PreviewDependencies: Dependencies {
    let appSettings: AppSettings = AppSettings(storage: UserDefaults())
    let notificationService: NotificationService = PreviewNotificationService()
    let reminderService: ReminderService = PreviewReminderService()
    let schedulingService: SchedulingService = PreviewSchedulingService()
    let cleaningService: CleaningService = PreviewCleaningService()
    let addCleaningUseCase: AddCleaningUseCase = PreviewAddCleaningUseCase()
    let deleteUseCase: DeleteUseCase = PreviewDeleteUseCase()
    let markCompleteUseCase: MarkCompleteUseCase = PreviewMarkCompleteUseCase()
}
