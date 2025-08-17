//
//  Date+Extensions.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 5/17/25.
//

import Foundation

extension Date {
    func dueDateComponents(_ calendar: Calendar = .current) -> DateComponents {
        calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self)
    }

    // Sat, May 17 at 11:51
    func formattedString() -> String {
        formatted(.dateTime
            .weekday(.abbreviated)
            .month(.abbreviated)
            .day(.defaultDigits)
            .hour(.defaultDigits(amPM: .abbreviated))
            .minute())
    }

    func relativeFormattedString() -> String {
        var format = Date.RelativeFormatStyle()
        format.presentation = .named
        return formatted(format)
    }
}
