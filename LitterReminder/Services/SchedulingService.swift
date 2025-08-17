//
//  SchedulingService.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 6/8/25.
//

import Foundation

protocol SchedulingService {
    func nextCleaningDate(
        _ currentDate: Date,
        calendar: Calendar
    ) -> Date

    func snoozeCleaningDate(
        _ existingDueDate: Date,
        calendar: Calendar
    ) -> Date
}

extension SchedulingService {
    func nextCleaningDate() -> Date {
        nextCleaningDate(.now, calendar: .current)
    }

    func snoozeCleaningDate(_ existingDueDate: Date) -> Date {
        snoozeCleaningDate(existingDueDate, calendar: .current)
    }
}

final class DefaultSchedulingService: SchedulingService {
    let appSettings: AppSettings

    init(appSettings: AppSettings) {
        self.appSettings = appSettings
    }

    func nextCleaningDate(
        _ currentDate: Date,
        calendar: Calendar
    ) -> Date {
        let daysOut = appSettings.nextCleaningDaysOut
        let hourOfDay = appSettings.nextCleaningHourOfDay
        guard let tempDate = calendar.date(byAdding: .day, value: daysOut, to: currentDate),
              let scheduledDate = calendar.date(bySettingHour: hourOfDay, minute: 0, second: 0, of: tempDate) else {
            fatalError("\(#function): Failed to create next date for currentDate: \(currentDate)")
        }

        return scheduledDate
    }

    func snoozeCleaningDate(
        _ existingDueDate: Date,
        calendar: Calendar
    ) -> Date {
        let daysOut = appSettings.nextCleaningDaysOut
        let hourOfDay = appSettings.nextCleaningHourOfDay
        guard let tempDate = calendar.date(byAdding: .day, value: daysOut, to: existingDueDate),
              let newDueDate = calendar.date(bySettingHour: hourOfDay, minute: 0, second: 0, of: tempDate) else {
            fatalError("\(#function): Failed to snooze existing existingDueDate: \(existingDueDate)")
        }

        return newDueDate
    }
}

final class DebugSchedulingService: SchedulingService {
    func nextCleaningDate(_ currentDate: Date, calendar: Calendar) -> Date {
        guard let scheduledDate = calendar.date(byAdding: .minute, value: 1, to: currentDate) else {
            fatalError("\(#function): Failed to create next date for currentDate: \(currentDate)")
        }

        return scheduledDate
    }

    func snoozeCleaningDate(_ existingDueDate: Date, calendar: Calendar) -> Date {
        guard let newDueDate = calendar.date(byAdding: .minute, value: 1, to: existingDueDate) else {
            fatalError("\(#function): Failed to snooze existing existingDueDate: \(existingDueDate)")
        }

        return newDueDate
    }
}

final class PreviewSchedulingService: SchedulingService {
    func snoozeCleaningDate(_ existingDueDate: Date, calendar: Calendar) -> Date {
        return Date().addingTimeInterval(86_400)
    }
    
    func nextCleaningDate(_ currentDate: Date, calendar: Calendar) -> Date {
        return Date().addingTimeInterval(86_400 * 2)
    }
}
