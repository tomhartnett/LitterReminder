//
//  ContentView+ViewModel.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 11/24/24.
//

import EventKit
import SwiftData
import SwiftUI

extension ContentView {
    @Observable
    class ViewModel {
        var currentDate: Date

        var cleanings = [Cleaning]()

        private var modelContext: ModelContext

        private var eventStore: EKEventStore

        init(modelContext: ModelContext, currentDate: Date = .now) {
            self.modelContext = modelContext
            self.currentDate = currentDate
            self.eventStore = EKEventStore()
            fetchData()
        }

        func addCleaning(_ currentDate: Date = .now) {
            let calendar = Calendar.autoupdatingCurrent
            let tempDate = calendar.date(byAdding: .day, value: 2, to: currentDate)!
            // TODO: settings to customize scheduling
            let scheduledDate = calendar.date(bySettingHour: 17, minute: 0, second: 0, of: tempDate)!

            addReminder(scheduledDate)
            // TODO: get unique id of reminder and save on cleaning object

            let cleaning = Cleaning(createdDate: currentDate, scheduledDate: scheduledDate)
            modelContext.insert(cleaning)
            saveChanges()
            fetchData()
        }

        func addReminder(_ date: Date) {
            guard let calendar = eventStore.calendars(for: .reminder).first(where: { $0.title == "Reminders" }) else {
                return
            }

            let reminder = EKReminder(eventStore: eventStore)
            reminder.title = "Scoop the poop"
            reminder.calendar = calendar

            let dueDateComps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            reminder.dueDateComponents = DateComponents(
                year: dueDateComps.year,
                month: dueDateComps.month,
                day: dueDateComps.day,
                hour: dueDateComps.hour,
                minute: dueDateComps.minute
            )

            do {
                try eventStore.save(reminder, commit: true)
            } catch {
                // Message error
            }

            // TODO: return unique id of reminder
        }

        func delete(atOffsets: IndexSet) {
            let cleaningsToDelete = atOffsets.compactMap({ cleanings[safe: $0] })
            for cleaning in cleaningsToDelete {
                modelContext.delete(cleaning)
            }
            fetchData()
        }

        func fetchData() {
            // TODO: add predicate to fetch only so far back
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

        func requestRemindersAccess() {
            let status = EKEventStore.authorizationStatus(for: .reminder)
            switch status {
            case .notDetermined:
                eventStore.requestFullAccessToReminders { granted, errorOrNil in
                    if let errorOrNil {
                        // Message error
                    }

                    if !granted {
                        // Message something
                    }
                }
            case .restricted:
                break // Need to prompt for something
            case .denied:
                break // Need to prompt for Settings
            case .fullAccess:
                break
            case .writeOnly:
                break // Should never happen
            @unknown default:
                break
            }
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
