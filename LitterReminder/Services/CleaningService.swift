import Foundation

protocol CleaningService {
    func getScheduledCleaning() throws -> Cleaning?

    func getCompletedCleanings() throws -> [Cleaning]

    func addCleaning(
        currentDate: Date,
        scheduledDate: Date,
        notificationID: String?,
        reminderID: String?
    ) throws -> String

    func markComplete(_ cleaning: Cleaning, currentDate: Date) throws

    func deleteCleaning(_ cleaning: Cleaning) throws

    func fetchAllCleanings(limit: Int?) throws -> [Cleaning]

    func fetchCleaning(byNotificationID id: String) throws -> Cleaning?

    func updateCleaning(_ cleaning: Cleaning) throws
}

final class DefaultCleaningService: CleaningService {
    private let repository: CleaningRepository
    
    init(repository: CleaningRepository) {
        self.repository = repository
    }
    
    func getScheduledCleaning() throws -> Cleaning? {
        let cleanings = try repository.fetchCleanings(limit: nil)
        return cleanings.filter { !$0.isComplete }
            .sorted { $0.scheduledDate < $1.scheduledDate }
            .first
    }
    
    func getCompletedCleanings() throws -> [Cleaning] {
        let cleanings = try repository.fetchCleanings(limit: nil)
        return cleanings.filter { $0.isComplete }
            .sorted { ($0.completedDate ?? .distantPast) > ($1.completedDate ?? .distantPast) }
    }
    
    func addCleaning(
        currentDate: Date,
        scheduledDate: Date,
        notificationID: String?,
        reminderID: String?
    ) throws -> String {
        let cleaning = Cleaning(
            createdDate: currentDate,
            scheduledDate: scheduledDate,
            notificationID: notificationID,
            reminderID: reminderID
        )

        try repository.addCleaning(cleaning)

        return cleaning.identifier
    }
    
    func markComplete(_ cleaning: Cleaning, currentDate: Date) throws {
        cleaning.completedDate = currentDate
        try repository.updateCleaning(cleaning)
    }
    
    func deleteCleaning(_ cleaning: Cleaning) throws {
        try repository.deleteCleaning(cleaning)
    }
    
    func fetchAllCleanings(limit: Int? = nil) throws -> [Cleaning] {
        try repository.fetchCleanings(limit: limit)
    }
    
    func fetchCleaning(byNotificationID id: String) throws -> Cleaning? {
        try repository.fetchCleaning(byNotificationID: id)
    }

    func updateCleaning(_ cleaning: Cleaning) throws {
        try repository.updateCleaning(cleaning)
    }
}

final class PreviewCleaningService: CleaningService {
    func getScheduledCleaning() throws -> Cleaning? {
        return Cleaning(
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

    func markComplete(_ cleaning: Cleaning, currentDate: Date) throws {}
    
    func deleteCleaning(_ cleaning: Cleaning) throws {}
    
    func fetchAllCleanings(limit: Int?) throws -> [Cleaning] {
        return []
    }
    
    func fetchCleaning(byNotificationID id: String) throws -> Cleaning? {
        return nil
    }

    func updateCleaning(_ cleaning: Cleaning) throws {}
}
