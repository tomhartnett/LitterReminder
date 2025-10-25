import Foundation

protocol MarkCompleteUseCase {
    func execute(for cleaning: Cleaning, completedDate: Date, nextCleaningDate: Date?) async throws
}

final class DefaultMarkCompleteUseCase: MarkCompleteUseCase {
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
    func execute(for cleaning: Cleaning, completedDate: Date, nextCleaningDate: Date?) async throws {
        try cleaningService.markComplete(cleaning, completedDate: completedDate)
        try reminderService.completeReminder(cleaning.reminderID, completionDate: completedDate)
        notificationService.deleteNotification(cleaning.notificationID)
        notificationService.removeAppBadge()

        if let nextCleaningDate {
            try await scheduleNext(for: nextCleaningDate)
        }
    }

    private func scheduleNext(for date: Date) async throws {
        var notificationID: String?
        if appSettings.isNotificationsEnabled {
            notificationID = try await notificationService.scheduleNotification(date)
        }

        var reminderID: String?
        if appSettings.isRemindersEnabled {
            reminderID = try reminderService.addReminder(date)
        }

        try cleaningService.addCleaning(
            scheduledDate: date,
            notificationID: notificationID,
            reminderID: reminderID
        )
    }
}

final class PreviewMarkCompleteUseCase: MarkCompleteUseCase {
    func execute(for cleaning: Cleaning, completedDate: Date, nextCleaningDate: Date?) async throws {}
}
