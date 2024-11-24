//
//  PreviewSampleData.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 11/24/24.
//

import Foundation
import SwiftData

@MainActor
let previewContainer: ModelContainer = {
    do {
        let container = try ModelContainer(
            for: Cleaning.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let modelContext = container.mainContext
        if try modelContext.fetch(FetchDescriptor<Cleaning>()).isEmpty {
            SampleCleaningsList.contents.forEach { container.mainContext.insert($0) }
        }
        return container
    } catch {
        fatalError("Failed to create container")
    }
}()

struct SampleCleaningsList {
    static var contents: [Cleaning] = [
        Cleaning(createdDate: .now.addingTimeInterval(-1), scheduledDate: .now.addingTimeInterval(3600 * 48), completedDate: nil),
        Cleaning(createdDate: .now.addingTimeInterval(-2), scheduledDate: .now.addingTimeInterval(3600 * 8), completedDate: nil),
        Cleaning(createdDate: .now.addingTimeInterval(-3), scheduledDate: .now, completedDate: nil),
        Cleaning(createdDate: .now.addingTimeInterval(-4), scheduledDate: .now.addingTimeInterval(-300), completedDate: nil),
        Cleaning(createdDate: .now.addingTimeInterval(-5), scheduledDate: .now.addingTimeInterval(-3600), completedDate: nil),
        Cleaning(createdDate: .now.addingTimeInterval(-6), scheduledDate: .now.addingTimeInterval(-3600 * 3), completedDate: nil),
        Cleaning(createdDate: .now.addingTimeInterval(-7), scheduledDate: .now.addingTimeInterval(-3600 * 3), completedDate: .now.addingTimeInterval(-3600 * 1.5))
    ]
}
