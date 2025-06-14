//
//  ReminderService.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 6/8/25.
//

import EventKit
import Foundation

protocol ReminderService {
    func addReminder(_ dueDate: Date) -> String?
    func completeReminder(_ identifier: String, completionDate: Date)
    func deleteReminder(_ identifier: String)
    func requestRemindersAccess()
}

class DefaultReminderService: ReminderService {
    let eventStore = EKEventStore()

    func addReminder(_ dueDate: Date) -> String? {
        guard let calendar = eventStore.calendars(for: .reminder).first(where: { $0.title == "Reminders" }) else {
            return nil
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
            
        }

        return nil
    }

    func completeReminder(_ identifier: String, completionDate: Date) {
        guard let reminder = eventStore.calendarItem(withIdentifier: identifier) as? EKReminder else {
            return
        }

        reminder.isCompleted = true
        reminder.completionDate = completionDate

        do {
            try eventStore.save(reminder, commit: true)
        } catch {

        }
    }

    func deleteReminder(_ identifier: String) {
        guard let reminder = eventStore.calendarItem(withIdentifier: identifier) as? EKReminder else {
            return
        }

        do {
            try eventStore.remove(reminder, commit: true)
        } catch {

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
}
