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
            return
        }

        switch response.actionIdentifier {
        case NotificationConstants.reminderLaterAction:
            guard let scheduleService = dependencies?.schedulingService,
                  let notificationService = dependencies?.notificationService,
                  let cleaningService = dependencies?.cleaningService,
                  let existingDueDate = content.userInfo[NotificationConstants.userInfoDueDate] as? Date,
                  let occurrence = content.userInfo[NotificationConstants.userInfoOccurrence] as? Int else {
                break
            }

            do {
                let existingNotificationID = response.notification.request.identifier
                let newDueDate = scheduleService.snoozeCleaningDate(existingDueDate)
                let newNotificationID = try await notificationService.scheduleNotification(
                    newDueDate,
                    occurrence: occurrence + 1
                )

                if let cleaning = try cleaningService.fetchAllCleanings().first(where: {
                    $0.notificationID == existingNotificationID
                }) {
                    cleaning.notificationID = newNotificationID

                    if let reminderID = cleaning.reminderID {
                        try dependencies?.reminderService.rescheduleReminder(reminderID, dueDate: newDueDate)
                    }

                    try cleaningService.updateCleaning(cleaning)
                }
            } catch {
                // TODO: handle error
            }

        default:
            break
        }
    }
}
