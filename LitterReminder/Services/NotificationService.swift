//
//  NotificationService.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 6/8/25.
//

import Foundation
import UserNotifications

protocol NotificationService {
    var isPermissionGranted: Bool { get async }
    func deleteNotification(_ identifier: String?)
    func registerNotifications()
    func removeAppBadge()
    func requestAuthorization() async throws -> Bool
    func scheduleNotification(_ dueDate: Date, occurrence: Int) async throws -> String
}

enum NotificationConstants {
    static let categoryIdentifier = "SCHEDULED_CLEANING"
    static let markCompleteAction = "MARK_COMPLETE"
    static let reminderLaterAction = "REMIND_LATER_1_DAY"
    static let userInfoDueDate = "DUE_DATE"
    static let userInfoOccurrence = "OCCURRENCE"
}

enum NotificationServiceError: Error, LocalizedError {
    case failedToAdd(Error?)
    case permissionsError(String, Bool)

    var errorDescription: String? {
        switch self {
        case .failedToAdd(let error):
            return String(localized: "Could not add notification to the system").appendingError(error)
        case .permissionsError(let message, _):
            return message
        }
    }
}

extension NotificationService {
    func scheduleNotification(_ dueDate: Date) async throws -> String {
        try await scheduleNotification(dueDate, occurrence: 1)
    }
}

final class DefaultNotificationService: NotificationService {
    let center = UNUserNotificationCenter.current()

    var isPermissionGranted: Bool {
        get async {
            let settings = await center.notificationSettings()
            let status = settings.authorizationStatus
            switch status {
            case .notDetermined:
                return false
            case .denied:
                return false
            case .authorized:
                return true
            case .provisional:
                return true
            case .ephemeral:
                return true
            @unknown default:
                return false
            }
        }
    }

    func registerNotifications() {
        let markCompleteAction = UNNotificationAction(
            identifier: NotificationConstants.markCompleteAction,
            title: String(localized: "Mark Complete")
        )
        let remindLaterAction = UNNotificationAction(
            identifier: NotificationConstants.reminderLaterAction,
            title: String(localized: "Remind Me Tomorrow")
        )
        let scheduledCleaningCategory = UNNotificationCategory(
            identifier: NotificationConstants.categoryIdentifier,
            actions: [markCompleteAction, remindLaterAction],
            intentIdentifiers: [],
            hiddenPreviewsBodyPlaceholder: "",
            options: .customDismissAction
        )

        center.setNotificationCategories([scheduledCleaningCategory])
    }

    func removeAppBadge() {
        center.setBadgeCount(0)
    }

    func requestAuthorization() async throws -> Bool {
        let settings = await center.notificationSettings()
        let status = settings.authorizationStatus

        switch status {
        case .notDetermined:
            return try await center.requestAuthorization(options: [.alert, .badge, .sound])

        case .denied:
            throw NotificationServiceError.permissionsError(
                String(localized: "Notifications were previously denied. Go to Settings to allow it."),
                true
            )
        case .authorized:
            return true

        case .provisional:
            return true

        case .ephemeral:
            return true

        @unknown default:
            throw NotificationServiceError.permissionsError(
                String(localized: "An unknown Notifications authorization status has been encountered."),
                false
            )
        }
    }

    func scheduleNotification(_ dueDate: Date, occurrence: Int) async throws -> String {
        let content = UNMutableNotificationContent()
        content.title = String(localized: "Litter Reminder")
        content.body = messageForNotification(occurrence)
        content.userInfo[NotificationConstants.userInfoDueDate] = dueDate
        content.userInfo[NotificationConstants.userInfoOccurrence] = occurrence
        content.categoryIdentifier = NotificationConstants.categoryIdentifier
        content.badge = NSNumber(value: 1)

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

    func deleteNotification(_ identifier: String?) {
        guard let identifier else { return }
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    private func messageForNotification(_ occurrence: Int) -> String {
        if occurrence <= 1 {
            return String(localized: "The litter box is due for cleaning")
        } else if occurrence == 2 {
            return String(localized: "2nd Notification: The litter box is due for cleaning")
        } else if occurrence == 3 {
            return String(localized: "3rd Notification 🙀: The litter box is due for cleaning")
        } else {
            return String(localized: "😿 The litter box is way overdue for cleaning 🙀")
        }
    }
}

final class PreviewNotificationService: NotificationService {
    var isPermissionGranted: Bool {
        true
    }

    func deleteNotification(_ identifier: String?) {}

    func registerNotifications() {}

    func removeAppBadge() {}

    func requestAuthorization() async throws -> Bool {
        true
    }

    func scheduleNotification(_ dueDate: Date, occurrence: Int) async throws -> String {
        UUID().uuidString
    }
}
