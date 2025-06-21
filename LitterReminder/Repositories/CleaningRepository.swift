import Foundation
import SwiftData

protocol CleaningRepository {
    func fetchCleanings(limit: Int?) throws -> [Cleaning]
    func fetchCleaning(byNotificationID id: String) throws -> Cleaning?
    func addCleaning(_ cleaning: Cleaning) throws
    func updateCleaning(_ cleaning: Cleaning) throws
    func deleteCleaning(_ cleaning: Cleaning) throws
}

final class DefaultCleaningRepository: CleaningRepository {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchCleanings(limit: Int? = nil) throws -> [Cleaning] {
        var descriptor = FetchDescriptor<Cleaning>(
            sortBy: [SortDescriptor(\.createdDate, order: .reverse)]
        )
        if let limit = limit {
            descriptor.fetchLimit = limit
        }
        return try modelContext.fetch(descriptor)
    }
    
    func fetchCleaning(byNotificationID id: String) throws -> Cleaning? {
        let descriptor = FetchDescriptor<Cleaning>(
            predicate: #Predicate { $0.notificationID == id }
        )
        return try modelContext.fetch(descriptor).first
    }
    
    func addCleaning(_ cleaning: Cleaning) throws {
        modelContext.insert(cleaning)
        try modelContext.save()
    }
    
    func updateCleaning(_ cleaning: Cleaning) throws {
        try modelContext.save()
    }
    
    func deleteCleaning(_ cleaning: Cleaning) throws {
        modelContext.delete(cleaning)
        try modelContext.save()
    }
} 
