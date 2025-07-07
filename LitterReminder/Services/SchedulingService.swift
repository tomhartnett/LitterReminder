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

    func nextCleaningDateComponents(
        _ currentDate: Date,
        calendar: Calendar
    ) -> DateComponents

    func snoozeCleaningDate(
        _ existingDueDate: Date,
        calendar: Calendar
    ) -> Date
}

extension SchedulingService {
    func nextCleaningDate() -> Date {
        nextCleaningDate(.now, calendar: .current)
    }

    func nextCleaningDate(after date: Date) -> Date {
        nextCleaningDate(date, calendar: .current)
    }

    func nextCleaningDateComponents() -> DateComponents {
        nextCleaningDateComponents(.now, calendar: .current)
    }

    func nextCleaningDateComponents(
        _ currentDate: Date,
        calendar: Calendar
    ) -> DateComponents {
        let scheduledDate = nextCleaningDate(currentDate, calendar: calendar)
        return scheduledDate.dueDateComponents(calendar)
    }

    func snoozeCleaningDate(_ existingDueDate: Date) -> Date {
        snoozeCleaningDate(existingDueDate, calendar: .current)
    }
}

extension Date {
    func dueDateComponents(_ calendar: Calendar = .current) -> DateComponents {
        calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self)
    }
}

final class DefaultSchedulingService: SchedulingService {
    func nextCleaningDate(
        _ currentDate: Date,
        calendar: Calendar
    ) -> Date {
        guard let tempDate = calendar.date(byAdding: .day, value: 2, to: currentDate),
              let scheduledDate = calendar.date(bySettingHour: 17, minute: 0, second: 0, of: tempDate) else {
            fatalError("\(#function): Failed to create next date for currentDate: \(currentDate)")
        }

        return scheduledDate
    }

    func snoozeCleaningDate(
        _ existingDueDate: Date,
        calendar: Calendar
    ) -> Date {
        guard let tempDate = calendar.date(byAdding: .day, value: 1, to: existingDueDate),
              let newDueDate = calendar.date(bySettingHour: 17, minute: 0, second: 0, of: tempDate) else {
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
