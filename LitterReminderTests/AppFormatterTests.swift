//
//  AppFormatterTests.swift
//  LitterReminderTests
//
//  Created by Tom Hartnett on 11/23/24.
//

import Foundation
import Testing
@testable import LitterReminder

struct AppFormatterTests {
    var scheduledDate: Date!

    init() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        scheduledDate = formatter.date(from: "2024-11-25 17:00")!
    }

    @Test func due_in_two_days() {
        // Given
        let currentDate = scheduledDate.addingTimeInterval(-3600 * 48)

        // When
        let string = AppDateFormatter.scheduledDateDisplayText(for: scheduledDate, relativeTo: currentDate)

        // Then
        #expect(string == "Monday at 5:00 PM")
    }

    @Test func due_in_eight_hours() {
        // Given
        let currentDate = scheduledDate.addingTimeInterval(-3600 * 8)

        // When
        let string = AppDateFormatter.scheduledDateDisplayText(for: scheduledDate, relativeTo: currentDate)

        // Then
        #expect(string == "Monday at 5:00 PM")
    }

    @Test func due_now() {
        // Given
        let currentDate = scheduledDate!

        // When
        let string = AppDateFormatter.scheduledDateDisplayText(for: scheduledDate, relativeTo: currentDate)

        // Then
        #expect(string == "now")
    }

    @Test func overdue_by_five_minutes() {
        // Given
        let currentDate = scheduledDate.addingTimeInterval(300)

        // When
        let string = AppDateFormatter.scheduledDateDisplayText(for: scheduledDate, relativeTo: currentDate)

        // Then
        #expect(string == "5 minutes ago")
    }

    @Test func overdue_by_one_hour() {
        // Given
        let currentDate = scheduledDate.addingTimeInterval(3600)

        // When
        let string = AppDateFormatter.scheduledDateDisplayText(for: scheduledDate, relativeTo: currentDate)

        // Then
        #expect(string == "1 hour ago")
    }

    @Test func overdue_by_sixteen_hours() {
        // Given
        let currentDate = scheduledDate.addingTimeInterval(3600 * 16)

        // When
        let string = AppDateFormatter.scheduledDateDisplayText(for: scheduledDate, relativeTo: currentDate)

        // Then
        #expect(string == "16 hours ago")
    }

    @Test func due_today() {
        // Given
        let currentDate = Date.now

        // When
        let string = AppDateFormatter.scheduledDateDisplayText(
            for: currentDate.addingTimeInterval(3600),
            relativeTo: currentDate
        )

        // Then
        #expect(string.starts(with: "Today at "))
    }

    @Test func due_tomorrow() {
        // Given
        let currentDate = Date.now

        // When
        let string = AppDateFormatter.scheduledDateDisplayText(
            for: currentDate.addingTimeInterval(24 * 3600),
            relativeTo: currentDate
        )

        // Then
        #expect(string.starts(with: "Tomorrow at "))
    }

    @Test func completed_today() {
        // Given
        let currentDate = Date.now

        // When
        let string = AppDateFormatter.completedDateDisplayText(currentDate.addingTimeInterval(-8 * 3600))

        // Then
        #expect(string.starts(with: "Today at "))
    }

    @Test func completed_yesterday() {
        // Given
        let currentDate = Date.now

        // When
        let string = AppDateFormatter.completedDateDisplayText(currentDate.addingTimeInterval(-24 * 3600))

        // Then
        #expect(string.starts(with: "Yesterday at "))
    }

    @Test func completed_two_days_ago() {
        // Given
        let currentDate = Date.now
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy h:mm a"

        // When
        let string = AppDateFormatter.completedDateDisplayText(currentDate.addingTimeInterval(-48 * 3600))

        // Then
        #expect(formatter.date(from: string) != nil)
    }
}
