//
//  NotificationService.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 6/8/25.
//

import Foundation
import UserNotifications

protocol NotificationService {
    func requestAuthorization() async
    func scheduleNotification(_ dueDate: Date) async
}

class DefaultNotificationService: NotificationService {
    let center = UNUserNotificationCenter.current()

    func requestAuthorization() async {
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .notDetermined else { return }

        do {
            try await center.requestAuthorization(options: [.alert, .badge, .sound])
        } catch {

        }
    }

    func scheduleNotification(_ dueDate: Date) async {
        let content = UNMutableNotificationContent()
        content.title = "Scoop the Poop"
        content.body = "The litter box is due for cleaning"

        let dateComponents = dueDate.dueDateComponents()
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        do {
            try await center.add(request)
        } catch {

        }
    }
}
