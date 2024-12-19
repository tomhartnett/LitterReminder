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
