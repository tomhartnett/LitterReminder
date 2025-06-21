//
//  ReminderService.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 6/8/25.
//

import EventKit
import Foundation

protocol ReminderService {
    func addReminder(_ dueDate: Date) throws -> String
    func completeReminder(_ identifier: String, completionDate: Date) throws
    func deleteReminder(_ identifier: String) throws
    func requestRemindersAccess()
    func rescheduleReminder(_ identifier: String, dueDate: Date) throws
}

enum ReminderServiceError: Error, LocalizedError {
    case calendarNotFound
    case failedToRemove(Error?)
    case failedToSave(Error?)

    var errorDescription: String? {
        switch self {
        case .calendarNotFound:
            return "Could not retrieve the Reminders calendar from the system."
        case .failedToRemove(let error):
            return "Could not remove reminder from the system".appendingError(error)
        case .failedToSave(let error):
            return "Could not save reminder to the system".appendingError(error)
        }
    }
}

final class DefaultReminderService: ReminderService {
    let eventStore = EKEventStore()

    func addReminder(_ dueDate: Date) throws -> String {
        guard let calendar = eventStore.calendars(for: .reminder).first(where: { $0.title == "Reminders" }) else {
            throw ReminderServiceError.calendarNotFound
        }

        let reminder = EKReminder(eventStore: eventStore)
        reminder.title = "Scoop the poop"
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

    func requestRemindersAccess() {
        let status = EKEventStore.authorizationStatus(for: .reminder)
        switch status {
        case .notDetermined:
            eventStore.requestFullAccessToReminders { granted, errorOrNil in
                if errorOrNil != nil {
                    // Message error
                }

                if !granted {
                    // Message something
                }
            }
        case .restricted:
            break // Need to prompt for something
        case .denied:
            break // Need to prompt for Settings
        case .fullAccess:
            break
        case .writeOnly:
            break // Should never happen
        @unknown default:
            break
        }
    }

    func rescheduleReminder(_ identifier: String, dueDate: Date) throws {
        guard let reminder = eventStore.calendarItem(withIdentifier: identifier) as? EKReminder else {
            return
        }

        reminder.dueDateComponents = dueDate.dueDateComponents()

        do {
            try eventStore.save(reminder, commit: true)
        } catch {
            throw ReminderServiceError.failedToSave(error)
        }
    }
}

final class PreviewReminderService: ReminderService {
    func addReminder(_ dueDate: Date) throws -> String {
        return UUID().uuidString
    }
    
    func completeReminder(_ identifier: String, completionDate: Date) throws {}

    func deleteReminder(_ identifier: String) throws {}

    func requestRemindersAccess() {}

    func rescheduleReminder(_ identifier: String, dueDate: Date) throws {}
}
