import Foundation
import SwiftData

protocol CleaningService {
    func getScheduledCleaning() throws -> Cleaning?

    func getCompletedCleanings() throws -> [Cleaning]

    @discardableResult
    func addCleaning(
        currentDate: Date,
        scheduledDate: Date,
        notificationID: String?,
        reminderID: String?
    ) throws -> String

    func markComplete(_ cleaning: Cleaning, completedDate: Date) throws

    func deleteCleaning(_ cleaning: Cleaning) throws

    func fetchAllCleanings() throws -> [Cleaning]

    func updateCleaning(_ cleaning: Cleaning) throws
}

extension CleaningService {
    @discardableResult
    func addCleaning(
        scheduledDate: Date,
        notificationID: String?,
        reminderID: String?
    ) throws -> String {
        return try addCleaning(
            currentDate: .now,
            scheduledDate: scheduledDate,
            notificationID: notificationID,
            reminderID: reminderID
        )
    }
}

final class DefaultCleaningService: CleaningService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func getScheduledCleaning() throws -> Cleaning? {
        let cleanings = try fetchAllCleanings()

        return cleanings.filter { !$0.isComplete }
            .sorted { $0.scheduledDate < $1.scheduledDate }
            .first
    }
    
    func getCompletedCleanings() throws -> [Cleaning] {
        let cleanings = try fetchAllCleanings()

        return cleanings.filter { $0.isComplete }
            .sorted { ($0.completedDate ?? .distantPast) > ($1.completedDate ?? .distantPast) }
    }

    @discardableResult
    func addCleaning(
        currentDate: Date,
        scheduledDate: Date,
        notificationID: String?,
        reminderID: String?
    ) throws -> String {
        let cleaning = Cleaning(
            identifier: UUID().uuidString,
            createdDate: currentDate,
            scheduledDate: scheduledDate,
            notificationID: notificationID,
            reminderID: reminderID
        )

        let identifier = cleaning.identifier

        let executor = DefaultSerialModelExecutor(modelContext: modelContext)
        executor.modelContext.insert(cleaning)
        try executor.modelContext.save()

        return identifier
    }
    
    func markComplete(_ cleaning: Cleaning, completedDate: Date) throws {
        cleaning.completedDate = completedDate
        try modelContext.save()
    }
    
    func deleteCleaning(_ cleaning: Cleaning) throws {
        modelContext.delete(cleaning)
        try modelContext.save()
    }
    
    func fetchAllCleanings() throws -> [Cleaning] {
        var descriptor = FetchDescriptor<Cleaning>(
            sortBy: [SortDescriptor(\.createdDate, order: .reverse)]
        )
        descriptor.fetchLimit = 20

        return try modelContext.fetch(descriptor)
    }

    func updateCleaning(_ cleaning: Cleaning) throws {
        try modelContext.save()
    }
}

final class PreviewCleaningService: CleaningService {
    func getScheduledCleaning() throws -> Cleaning? {
        return Cleaning(
            identifier: UUID().uuidString,
            createdDate: Date().addingTimeInterval(-86_400),
            scheduledDate: Date().addingTimeInterval(86_400),
            completedDate: nil,
            notificationID: nil,
            reminderID: nil
        )
    }
    
    func getCompletedCleanings() throws -> [Cleaning] {
        return []
    }
    
    func addCleaning(
        currentDate: Date,
        scheduledDate: Date,
        notificationID: String?,
        reminderID: String?
    ) throws -> String {
        return UUID().uuidString
    }

    func markComplete(_ cleaning: Cleaning, completedDate: Date) throws {}

    func deleteCleaning(_ cleaning: Cleaning) throws {}
    
    func fetchAllCleanings() throws -> [Cleaning] {
        return []
    }

    func updateCleaning(_ cleaning: Cleaning) throws {}
}
