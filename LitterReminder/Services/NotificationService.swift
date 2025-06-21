//
//  NotificationService.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 6/8/25.
//

import Foundation
import UserNotifications

protocol NotificationService {
    func deleteNotification(_ identifier: String)
    func registerNotifications()
    func requestAuthorization() async throws
    func scheduleNotification(_ dueDate: Date, occurrence: Int) async throws -> String
}

enum NotificationConstants {
    static let categoryIdentifier = "SCHEDULED_CLEANING"
    static let reminderLaterAction = "REMIND_LATER_1_DAY"
    static let userInfoDueDate = "DUE_DATE"
    static let userInfoOccurrence = "OCCURRENCE"
}

enum NotificationServiceError: Error, LocalizedError {
    case failedToAdd(Error?)
    case requestAuthorizationError(Error?)

    var errorDescription: String? {
        switch self {
        case .failedToAdd(let error):
            return "Could not add notification to the system".appendingError(error)
        case .requestAuthorizationError(let error):
            return "Error requesting authorization for notifications".appendingError(error)
        }
    }
}

extension NotificationService {
    func scheduleNotification(_ dueDate: Date) async throws -> String {
        try await scheduleNotification(dueDate, occurrence: 1)
    }
}

class DefaultNotificationService: NotificationService {
    let center = UNUserNotificationCenter.current()

    func registerNotifications() {
        let remindLaterAction = UNNotificationAction(identifier: NotificationConstants.reminderLaterAction, title: "Remind Me Tomorrow")
        let scheduledCleaningCategory = UNNotificationCategory(
            identifier: NotificationConstants.categoryIdentifier,
            actions: [remindLaterAction],
            intentIdentifiers: [],
            hiddenPreviewsBodyPlaceholder: "",
            options: .customDismissAction
        )

        center.setNotificationCategories([scheduledCleaningCategory])
    }

    func requestAuthorization() async throws {
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .notDetermined else { return }

        do {
            try await center.requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            throw NotificationServiceError.requestAuthorizationError(error)
        }
    }

    func scheduleNotification(_ dueDate: Date, occurrence: Int) async throws -> String {
        let content = UNMutableNotificationContent()
        content.title = "Litter Reminder"
        content.body = messageForNotification(occurrence)
        content.userInfo[NotificationConstants.userInfoDueDate] = dueDate
        content.userInfo[NotificationConstants.userInfoOccurrence] = occurrence
        content.categoryIdentifier = NotificationConstants.categoryIdentifier

        let dateComponents = dueDate.dueDateComponents()
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        let identifier = UUID().uuidString
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        do {
            try await center.add(request)
            return identifier
        } catch {
            throw NotificationServiceError.failedToAdd(error)
        }
    }

    func deleteNotification(_ identifier: String) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    private func messageForNotification(_ occurrence: Int) -> String {
        if occurrence <= 1 {
            return "The litter box is due for cleaning"
        } else if occurrence == 2 {
            return "2nd Notification: The litter box is due for cleaning"
        } else if occurrence == 3 {
            return "3rd Notification 🙀: The litter box is due for cleaning"
        } else {
            return "😿 The litter box is way overdue for cleaning 🙀"
        }
    }
}
