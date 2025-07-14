import Foundation

protocol MarkCompleteUseCase {
    func execute(for cleaning: Cleaning, completedDate: Date) async throws
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

    func execute(for cleaning: Cleaning, completedDate: Date) async throws {
        // Mark the current cleaning as complete
        try cleaningService.markComplete(cleaning, completedDate: completedDate)

        // Complete the reminder if it exists
        if let reminderID = cleaning.reminderID {
            try reminderService.completeReminder(reminderID, completionDate: completedDate)
        }

        if let notificationID = cleaning.notificationID {
            notificationService.deleteNotification(notificationID)
        }

        let scheduledDate = schedulingService.nextCleaningDate(after: completedDate)
        let notificationID = try await notificationService.scheduleNotification(scheduledDate)
        let reminderID = try reminderService.addReminder(scheduledDate)

        try cleaningService.addCleaning(
            scheduledDate: scheduledDate,
            notificationID: notificationID,
            reminderID: reminderID
        )
    }
}

final class PreviewMarkCompleteUseCase: MarkCompleteUseCase {
    func execute(for cleaning: Cleaning, completedDate: Date) async throws {}
}
