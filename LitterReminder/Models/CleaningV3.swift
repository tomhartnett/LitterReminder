//
//  CleaningV3.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 8/24/25.
//

import Foundation
import SwiftData

enum CleaningSchemaV3: VersionedSchema {
    static var versionIdentifier = Schema.Version(3, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Cleaning.self]
    }

    @Model
    class Cleaning {
        var identifier: String = UUID().uuidString

        var createdDate: Date = Date()

        var scheduledDate: Date = Date()

        var completedDate: Date?

        var notificationID: String?

        var reminderID: String?

        var isComplete: Bool {
            completedDate != nil
        }

        init(
            identifier: String,
            createdDate: Date,
            scheduledDate: Date,
            completedDate: Date? = nil,
            notificationID: String? = nil,
            reminderID: String? = nil
        ) {
            self.identifier = identifier
            self.createdDate = createdDate
            self.scheduledDate = scheduledDate
            self.completedDate = completedDate
            self.notificationID = notificationID
            self.reminderID = reminderID
        }
    }
}
