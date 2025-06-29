import Foundation

protocol MarkCompleteUseCase {
    func execute(for cleaning: Cleaning, currentDate: Date) async throws
}

final class DefaultMarkCompleteUseCase: MarkCompleteUseCase {
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

    func execute(for cleaning: Cleaning, currentDate: Date) async throws {
        // Mark the current cleaning as complete
        try cleaningService.markComplete(cleaning, currentDate: currentDate)

        // Complete the reminder if it exists
        if let reminderID = cleaning.reminderID {
            try reminderService.completeReminder(reminderID, completionDate: currentDate)
        }

        // Schedule the next cleaning
        let nextScheduledDate = schedulingService.nextCleaningDate()
        let newReminderID = try reminderService.addReminder(nextScheduledDate)
        let newNotificationID = try await notificationService.scheduleNotification(nextScheduledDate)

        // TODO: pass cleaningID to notificationService and save it on the notification
        let cleaningID = try cleaningService.addCleaning(
            currentDate: currentDate,
            scheduledDate: nextScheduledDate,
            notificationID: newNotificationID,
            reminderID: newReminderID
        )
    }
}

final class PreviewMarkCompleteUseCase: MarkCompleteUseCase {
    func execute(for cleaning: Cleaning, currentDate: Date) async throws {}
}
