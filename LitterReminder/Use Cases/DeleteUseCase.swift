//
//  DeleteUseCase.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 7/14/25.
//

import Foundation

protocol DeleteUseCase {
    func execute(_ cleaning: Cleaning)
}

final class DefaultDeleteUseCase: DeleteUseCase {
    private let cleaningService: CleaningService
    private let reminderService: ReminderService
    private let notificationService: NotificationService

    init(
        cleaningService: CleaningService,
        reminderService: ReminderService,
        notificationService: NotificationService
    ) {
        self.cleaningService = cleaningService
        self.reminderService = reminderService
        self.notificationService = notificationService
    }

    @MainActor
    func execute(_ cleaning: Cleaning) {
        // TODO: handle error
        try? reminderService.deleteReminder(cleaning.reminderID)

        notificationService.deleteNotification(cleaning.notificationID)

        // TODO: handle error
        try? cleaningService.deleteCleaning(cleaning)
    }
}

final class PreviewDeleteUseCase: DeleteUseCase {
    func execute(_ cleaning: Cleaning) {}
}
