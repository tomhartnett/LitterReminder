//
//  CleaningMigrationPlan.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 6/26/25.
//

import SwiftData

fileprivate var v1CleaningsInMigration = [CleaningSchemaV1.Cleaning]()

enum CleaningMigrationPlan: SchemaMigrationPlan {
    static let migrateV1toV2 = MigrationStage.custom(
        fromVersion: CleaningSchemaV1.self,
        toVersion: CleaningSchemaV2.self,
        willMigrate: { context in
            let cleanings = try context.fetch(FetchDescriptor<CleaningSchemaV1.Cleaning>())

            v1CleaningsInMigration = cleanings

            for cleaningV1 in cleanings {
                context.delete(cleaningV1)
            }

            try context.save()
        },
        didMigrate: { context in
            for cleaningV1 in v1CleaningsInMigration {
                // created v2 here and delete v1, then save all?
                let cleaningV2 = CleaningSchemaV2.Cleaning(
                    createdDate: cleaningV1.createdDate,
                    scheduledDate: cleaningV1.scheduledDate,
                    completedDate: cleaningV1.completedDate,
                    notificationID: cleaningV1.notificationID,
                    reminderID: cleaningV1.reminderID
                )

                context.insert(cleaningV2)
            }

            try context.save()
        }
    )

    static let migrateV2toV3 = MigrationStage.lightweight(
        fromVersion: CleaningSchemaV2.self,
        toVersion: CleaningSchemaV3.self
    )

    static var schemas: [any VersionedSchema.Type] {
        [
            CleaningSchemaV1.self,
            CleaningSchemaV2.self,
            CleaningSchemaV3.self
        ]
    }

    static var stages: [MigrationStage] {
        [
            migrateV1toV2,
            migrateV2toV3
        ]
    }
}
