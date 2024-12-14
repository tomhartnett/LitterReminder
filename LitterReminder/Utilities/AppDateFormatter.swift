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
        completedDateFormatter.string(from: completedDate)
    }

    static func scheduledDateDisplayText(
        for date: Date,
        relativeTo currentDate: Date = Date()
    ) -> String {

        let calendar = Calendar.current
        let isToday = calendar.isDateInToday(date)
        let isTomorrow = calendar.isDateInTomorrow(date)
        let interval = date.timeIntervalSince(currentDate)

        if isToday || isTomorrow {
            return todayTomorrowDateFormatter.string(from: date)
        } else if interval > 0 && interval < 518_400 {
            // Within next 6 days
            return scheduledDateFormatter.string(from: date)
        } else {
            return relativeDateFormatter.localizedString(for: date, relativeTo: currentDate)
        }
    }
}
