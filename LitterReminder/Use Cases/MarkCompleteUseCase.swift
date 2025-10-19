import Foundation

protocol MarkCompleteUseCase {
    func execute(for cleaning: Cleaning, completedDate: Date, scheduleNextCleaning: Bool) async throws
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
    func execute(for cleaning: Cleaning, completedDate: Date, scheduleNextCleaning: Bool) async throws {
        try cleaningService.markComplete(cleaning, completedDate: completedDate)
        try reminderService.completeReminder(cleaning.reminderID, completionDate: completedDate)
        notificationService.deleteNotification(cleaning.notificationID)
        notificationService.removeAppBadge()

        if scheduleNextCleaning {
            try await scheduleNext(after: completedDate)
        }
    }

    private func scheduleNext(after completedDate: Date) async throws {
        let daysOut = appSettings.nextCleaningDaysOut
        let hourOfDay = appSettings.nextCleaningHourOfDay
        let calendar = Calendar.current
        guard let tempDate = calendar.date(byAdding: .day, value: daysOut, to: completedDate),
              let scheduledDate = calendar.date(bySettingHour: hourOfDay, minute: 0, second: 0, of: tempDate) else {
            // TODO: throw new error type
            fatalError("\(#function): Failed to create next date for completedDate: \(completedDate)")
        }

        var notificationID: String?
        if appSettings.isNotificationsEnabled {
            notificationID = try await notificationService.scheduleNotification(scheduledDate)
        }

        var reminderID: String?
        if appSettings.isRemindersEnabled {
            reminderID = try reminderService.addReminder(scheduledDate)
        }

        try cleaningService.addCleaning(
            scheduledDate: scheduledDate,
            notificationID: notificationID,
            reminderID: reminderID
        )
    }
}

final class PreviewMarkCompleteUseCase: MarkCompleteUseCase {
    func execute(for cleaning: Cleaning, completedDate: Date, scheduleNextCleaning: Bool) async throws {}
}
