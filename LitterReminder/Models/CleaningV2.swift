//
//  CleaningV2.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 6/25/25.
//

import Foundation
import SwiftData

enum CleaningSchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Cleaning.self]
    }

    @Model
    class Cleaning {
        @Attribute(.unique)
        var identifier: UUID

        var createdDate: Date

        var scheduledDate: Date

        var completedDate: Date?

        var notificationID: String?

        var reminderID: String?

        var isComplete: Bool {
            completedDate != nil
        }

        init(
            identifier: UUID = UUID(),
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
