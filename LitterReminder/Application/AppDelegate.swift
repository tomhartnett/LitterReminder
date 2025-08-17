//
//  AppDelegate.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 6/14/25.
//

import SwiftData
import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    var dependencies: Dependencies?
    var modelContainer: ModelContainer?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        DefaultNotificationService().registerNotifications()

        UNUserNotificationCenter.current().delegate = self

        return true
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

        guard let cleaning = try? cleaningService.fetchAllCleanings().first(where: {
            $0.notificationID == existingNotificationID
        }) else {
            // TODO: log error
            return
        }

        switch response.actionIdentifier {
        case NotificationConstants.markCompleteAction:
            do {
                try await dependencies?.markCompleteUseCase.execute(for: cleaning, completedDate: .now, scheduleNextCleaning: true)
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
