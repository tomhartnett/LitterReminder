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
        if let reminderID = cleaning.reminderID {
            // TODO: handle error
            try? reminderService.deleteReminder(reminderID)
        }

        if let notificationID = cleaning.notificationID {
            notificationService.deleteNotification(notificationID)
        }

        do {
            try cleaningService.deleteCleaning(cleaning)
        } catch {
            // TODO: handle error
        }
    }
}

final class PreviewDeleteUseCase: DeleteUseCase {
    func execute(_ cleaning: Cleaning) {}
}
