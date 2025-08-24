//
//  ReminderService.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 6/8/25.
//

import EventKit
import Foundation

protocol ReminderService {
    var isPermissionGranted: Bool { get }
    func addReminder(_ dueDate: Date) throws -> String
    func completeReminder(_ identifier: String, completionDate: Date) throws
    func deleteReminder(_ identifier: String) throws
    func requestRemindersAccess() async throws -> Bool
}

enum ReminderServiceError: Error, LocalizedError {
    case calendarNotFound
    case failedToRemove(Error?)
    case failedToSave(Error?)
    case permissionsError(String, Bool)

    var errorDescription: String? {
        switch self {
        case .calendarNotFound:
            return String(localized: "Could not retrieve the Reminders calendar from the system.")
        case .failedToRemove(let error):
            return String(localized: "Could not remove reminder from the system").appendingError(error)
        case .failedToSave(let error):
            return String(localized: "Could not save reminder to the system").appendingError(error)
        case .permissionsError(let message, _):
            return message
        }
    }
}

final class DefaultReminderService: ReminderService {
    let eventStore = EKEventStore()

    var isPermissionGranted: Bool {
        let status = EKEventStore.authorizationStatus(for: .reminder)
        switch status {
        case .notDetermined:
            return false
        case .restricted:
            return false
        case .denied:
            return false
        case .fullAccess:
            return true
        case .writeOnly:
            return false
        @unknown default:
            return false
        }
    }

    func addReminder(_ dueDate: Date) throws -> String {
        guard let calendar = eventStore.calendars(for: .reminder).first(where: { $0.title == "Reminders" }) else {
            throw ReminderServiceError.calendarNotFound
        }

        let reminder = EKReminder(eventStore: eventStore)
        reminder.title = String(localized: "Scoop the poop")
        reminder.calendar = calendar
        reminder.dueDateComponents = dueDate.dueDateComponents()
        reminder.addAlarm(EKAlarm(absoluteDate: dueDate))

        do {
            try eventStore.save(reminder, commit: true)
            return reminder.calendarItemIdentifier
        } catch {
            throw ReminderServiceError.failedToSave(error)
        }
    }

    func completeReminder(_ identifier: String, completionDate: Date) throws {
        guard let reminder = eventStore.calendarItem(withIdentifier: identifier) as? EKReminder else {
            return
        }

        reminder.isCompleted = true
        reminder.completionDate = completionDate

        do {
            try eventStore.save(reminder, commit: true)
        } catch {
            throw ReminderServiceError.failedToSave(error)
        }
    }

    func deleteReminder(_ identifier: String) throws {
        guard let reminder = eventStore.calendarItem(withIdentifier: identifier) as? EKReminder else {
            return
        }

        do {
            try eventStore.remove(reminder, commit: true)
        } catch {
            throw ReminderServiceError.failedToRemove(error)
        }
    }

    func requestRemindersAccess() async throws -> Bool {
        let status = EKEventStore.authorizationStatus(for: .reminder)
        switch status {
        case .notDetermined:
            return try await eventStore.requestFullAccessToReminders()

        case .restricted:
            throw ReminderServiceError.permissionsError(
                String(localized: "Reminders access is restricted on this device."),
                false
            )
        case .denied:
            throw ReminderServiceError.permissionsError(
                String(localized: "Reminders access was previously denied. Go to Settings to allow it."),
                true
            )
        case .fullAccess:
            return true

        case .writeOnly:
            // Should never happen
            throw ReminderServiceError.permissionsError(
                String(localized: "Reminders access is write-only on this device. This is insufficient for this feature."),
                false
            )

        @unknown default:
            throw ReminderServiceError.permissionsError(
                String(localized: "An unknown Reminders authorization status has been encountered."),
                false
            )
        }
    }
}

final class PreviewReminderService: ReminderService {
    var isPermissionGranted: Bool {
        true
    }

    func addReminder(_ dueDate: Date) throws -> String {
        UUID().uuidString
    }
    
    func completeReminder(_ identifier: String, completionDate: Date) throws {}

    func deleteReminder(_ identifier: String) throws {}

    func requestRemindersAccess() async throws -> Bool {
        true
    }
}
