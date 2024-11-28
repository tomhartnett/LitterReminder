//
//  ContentView+ViewModel.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 11/24/24.
//

import SwiftData
import SwiftUI

extension ContentView {
    @Observable
    class ViewModel {
        var currentDate: Date

        var cleanings = [Cleaning]()

        private var modelContext: ModelContext

        init(modelContext: ModelContext, currentDate: Date = .now) {
            self.modelContext = modelContext
            self.currentDate = currentDate
            fetchData()
        }

        func addCleaning(_ currentDate: Date = .now) {
            let calendar = Calendar.autoupdatingCurrent
            let tempDate = calendar.date(byAdding: .day, value: 2, to: currentDate)!
            let scheduledDate = calendar.date(bySettingHour: 17, minute: 0, second: 0, of: tempDate)!
            let cleaning = Cleaning(createdDate: currentDate, scheduledDate: scheduledDate)
            modelContext.insert(cleaning)
            saveChanges()
            fetchData()
        }

        func delete(atOffsets: IndexSet) {
            let cleaningsToDelete = atOffsets.compactMap({ cleanings[safe: $0] })
            for cleaning in cleaningsToDelete {
                modelContext.delete(cleaning)
            }
            fetchData()
        }

        func fetchData() {
            do {
                let descriptor = FetchDescriptor<Cleaning>(
                    sortBy: [
                        SortDescriptor(\.createdDate, order: .reverse)
                    ]
                )
                cleanings = try modelContext.fetch(descriptor)
            } catch {
                print("Fetch failed")
            }
        }

        func markComplete(_ currentDate: Date = .now) {
            guard let mostRecent = cleanings.first, mostRecent.completedDate == nil else {
                return
            }

            mostRecent.completedDate = currentDate
            saveChanges()
            fetchData()
        }

        func updateCurrentDate() {
            currentDate = .now
        }

        private func saveChanges() {
            do {
                try modelContext.save()
            } catch {
                print("Saved failed")
            }
        }
    }
}
