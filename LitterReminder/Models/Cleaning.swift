//
//  Cleaning.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 11/23/24.
//

import Foundation
import SwiftData

@Model
class Cleaning {
    var createdDate: Date
    var scheduledDate: Date
    var completedDate: Date?

    var isComplete: Bool {
        completedDate != nil
    }

    init(createdDate: Date, scheduledDate: Date, completedDate: Date? = nil) {
        self.createdDate = createdDate
        self.scheduledDate = scheduledDate
        self.completedDate = completedDate
    }
}

extension Cleaning {
    func status(_ currentDate: Date = .now) -> CleaningStatus {
        if completedDate != nil {
            return .completed
        } else {
            if currentDate < scheduledDate {
                return .scheduled
            } else {
                let timeSinceDue = currentDate.timeIntervalSince(scheduledDate)
                if timeSinceDue < 3600 {
                    return .due
                } else {
                    return .overdue
                }
            }
        }
    }
}
