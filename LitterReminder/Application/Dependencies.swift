//
//  Dependencies.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 6/8/25.
//

import Foundation

protocol Dependencies {
    var notificationService: NotificationService { get }
    var reminderService: ReminderService { get }
    var schedulingService: SchedulingService { get }
}

class AppDependencies: Dependencies {
    lazy var notificationService: NotificationService = DefaultNotificationService()
    lazy var reminderService: ReminderService = DefaultReminderService()
    lazy var schedulingService: SchedulingService = DefaultSchedulingService()
}
