//
//  AppDelegate.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 6/14/25.
//

import CoreData
import SwiftData
import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    var dependencies: Dependencies?
    var modelContainer: ModelContainer?
    var homeViewModel: HomeViewModel?

    private var remoteChangeObserver: NSObjectProtocol?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        DefaultNotificationService().registerNotifications()

        UNUserNotificationCenter.current().delegate = self

        observeRemoteChanges()

        return true
    }

    // SwiftData's CloudKit-backed store merges incoming changes into the
    // main context in the background, but doesn't otherwise notify the app.
    // Since the UI is driven by HomeViewModel's cached array rather than
    // @Query, we need to explicitly refetch when that happens.
    private func observeRemoteChanges() {
        remoteChangeObserver = NotificationCenter.default.addObserver(
            forName: .NSPersistentStoreRemoteChange,
            object: nil,
            queue: nil
        ) { [weak self] _ in
            Task { @MainActor in
                self?.homeViewModel?.fetchData()
            }
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let content = response.notification.request.content
        guard content.categoryIdentifier == NotificationConstants.categoryIdentifier else {
            // TODO: log error
            return
        }

        guard let notificationService = dependencies?.notificationService,
              let cleaningService = dependencies?.cleaningService else {
            // TODO: log error
            return
        }

        let existingNotificationID = response.notification.request.identifier

        guard let cleaning = try? cleaningService
            .fetchAllCleanings()
            .first(where: { $0.notificationID == existingNotificationID }) else {
            // TODO: log error
            return
        }

        guard !cleaning.isComplete else {
            // It's possible the cleaning was already completed in the app,
            // and then the user later marked complete on the notification.
            // In that case, there's no work to do, and it's not an error.
            // TODO: maybe log something
            return
        }

        switch response.actionIdentifier {
        case NotificationConstants.markCompleteAction:
            do {
                let scheduleNextCleaning = dependencies?.appSettings.isAutoScheduleEnabled ?? false
                let nextCleaningDate = dependencies?.schedulingService.nextCleaningDate()
                try await dependencies?.markCompleteUseCase.execute(
                    for: cleaning,
                    completedDate: .now,
                    nextCleaningDate: scheduleNextCleaning ? nextCleaningDate : nil
                )
            } catch {
                // TODO: handle error
            }

        case NotificationConstants.reminderLaterAction:
            guard let existingDueDate = content.userInfo[NotificationConstants.userInfoDueDate] as? Date,
                  let newDueDate = Calendar.current.date(byAdding: .day, value: 1, to: existingDueDate),
                  let occurrence = content.userInfo[NotificationConstants.userInfoOccurrence] as? Int else {
                // TODO: log error
                break
            }

            do {
                let newNotificationID = try await notificationService.scheduleNotification(
                    newDueDate,
                    occurrence: occurrence + 1
                )

                cleaning.notificationID = newNotificationID

                try cleaningService.updateCleaning(cleaning)
            } catch {
                // TODO: handle error
            }

        default:
            // TODO: log error
            break
        }
    }
}
