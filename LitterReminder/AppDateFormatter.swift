//
//  AppDateFormatter.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 11/23/24.
//

import Foundation

class AppDateFormatter {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, h:mm a"
        return formatter
    }()

    private static let relativeDateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        return formatter
    }()

    static func dateDisplayText(
        for date: Date,
        relativeTo currentDate: Date = Date()
    ) -> String {

        let interval = date.timeIntervalSince(currentDate)

        if interval > 0 && interval < 518_400 {
            // Within next 6 days
            return dateFormatter.string(from: date)
        } else {
            return relativeDateFormatter.localizedString(for: date, relativeTo: currentDate)
        }
    }
}
