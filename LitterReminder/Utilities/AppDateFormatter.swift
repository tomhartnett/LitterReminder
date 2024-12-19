//
//  AppDateFormatter.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 11/23/24.
//

import Foundation

class AppDateFormatter {
    private static let completedDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy h:mm a"
        return formatter
    }()

    private static let relativeDateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        return formatter
    }()

    private static let scheduledDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE 'at' h:mm a"
        return formatter
    }()

    private static let todayTomorrowDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .medium
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()

    static func completedDateDisplayText(_ completedDate: Date) -> String {
        let calendar = Calendar.current
        let isToday = calendar.isDateInToday(completedDate)
        let isYesterday = calendar.isDateInYesterday(completedDate)

        if isToday || isYesterday {
            return todayTomorrowDateFormatter.string(from: completedDate)
        } else {
            return completedDateFormatter.string(from: completedDate)
        }
    }

    static func scheduledDateDisplayText(
        for date: Date,
        relativeTo currentDate: Date = Date()
    ) -> String {

        let calendar = Calendar.current
        let isToday = calendar.isDateInToday(date)
        let isTomorrow = calendar.isDateInTomorrow(date)

        if date <= currentDate {
            return relativeDateFormatter.localizedString(for: date, relativeTo: currentDate)
        } else {
            if isToday || isTomorrow {
                return todayTomorrowDateFormatter.string(from: date)
            } else {
                return scheduledDateFormatter.string(from: date)
            }
        }
    }
}
