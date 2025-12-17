//
//  HomeViewModel.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 11/24/24.
//

import EventKit
import SwiftData
import SwiftUI

@Observable
final class HomeViewModel {
    var currentDate: Date

    var errorMessage: String?

    var cleanings = [Cleaning]()

    var completedCleanings: [Cleaning] {
        cleanings.filter({ $0.isComplete }).sorted(by: {
            let completed1 = $0.completedDate ?? Date.distantPast
            let completed2 = $1.completedDate ?? Date.distantPast

            return completed1 > completed2
        })
    }

    var reversedCleanings: [Cleaning] {
        cleanings.sorted(by: { $0.createdDate < $1.createdDate })
    }

    var hasCompletedCleanings: Bool {
        !completedCleanings.isEmpty
    }

    var hasScheduledCleaning: Bool {
        scheduledCleaning != nil
    }

    var scheduledCleaning: Cleaning? {
        cleanings
            .filter({ !$0.isComplete })
            .sorted(by: { $0.scheduledDate < $1.scheduledDate })
            .first
    }

    var nextScheduleDateFromNow: Date {
        dependencies.schedulingService.nextCleaningDate()
    }

    private let dependencies: Dependencies

    init(
        dependencies: Dependencies,
        currentDate: Date = .now
    ) {
        self.dependencies = dependencies
        self.currentDate = currentDate
        fetchData()
    }

    func addCleaning(_ currentDate: Date = .now) {
        Task { @MainActor in
            do {
                try await dependencies.addCleaningUseCase.execute(currentDate: currentDate)
                fetchData()
            } catch {
                // TODO: handle error
            }
        }
    }

    func delete(_ cleaning: Cleaning) {
        dependencies.deleteUseCase.execute(cleaning)
        fetchData()
    }

    func fetchData() {
        do {
            cleanings = try dependencies.cleaningService.fetchAllCleanings()
        } catch {
            // TODO: handle error
        }
    }

    func markComplete(_ currentDate: Date = .now, nextCleaningDate: Date?) {
        guard let scheduledCleaning else {
            return
        }

        Task { @MainActor in
            do {
                try await dependencies.markCompleteUseCase.execute(
                    for: scheduledCleaning,
                    completedDate: currentDate,
                    nextCleaningDate: nextCleaningDate
                )
                fetchData()
            } catch {
                // TODO: handle error
            }
        }
    }

    func updateCurrentDate() {
        currentDate = .now
    }
}
