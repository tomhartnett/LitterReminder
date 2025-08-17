//
//  SettingsViewModel.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 8/17/25.
//

import SwiftUI

@Observable
final class SettingsViewModel {
    var isNotificationsEnabled: Bool

    var isRemindersEnabled: Bool

    var settingsAlert: AlertDetails?

    private let appSettings: AppSettings
    private let dependencies: Dependencies

    init(
        appSettings: AppSettings,
        dependencies: Dependencies
    ) {
        self.appSettings = appSettings
        self.dependencies = dependencies

        isNotificationsEnabled = appSettings.isNotificationsEnabled
        isRemindersEnabled = appSettings.isRemindersEnabled
    }

    func enableNotifications() async {
        isNotificationsEnabled = true
        Task {
            do {
                let isGranted = try await dependencies.notificationService.requestAuthorization()
                isNotificationsEnabled = isGranted
                appSettings.isNotificationsEnabled = isGranted
            } catch NotificationServiceError.permissionsError(let message, let isRecoverable) {
                isNotificationsEnabled = false
                appSettings.isNotificationsEnabled = false
                settingsAlert = AlertDetails(message: message, showSettingsButton: isRecoverable)
            } catch {
                isNotificationsEnabled = false
                appSettings.isNotificationsEnabled = false
                settingsAlert = AlertDetails(message: error.localizedDescription, showSettingsButton: false)
            }
        }
    }

    func disableNotifications() {
        isNotificationsEnabled = false
        appSettings.isNotificationsEnabled = false
    }

    func enableReminders() {
        isRemindersEnabled = true
        Task {
            do {
                let isGranted = try await dependencies.reminderService.requestRemindersAccess()
                isRemindersEnabled = isGranted
                appSettings.isRemindersEnabled = isGranted
            } catch ReminderServiceError.permissionsError(let message, let isRecoverable) {
                isRemindersEnabled = false
                appSettings.isRemindersEnabled = false
                settingsAlert = AlertDetails(message: message, showSettingsButton: isRecoverable)
            } catch {
                isRemindersEnabled = false
                appSettings.isRemindersEnabled = false
                settingsAlert = AlertDetails(message: error.localizedDescription, showSettingsButton: false)
            }
        }
    }

    func disableReminders() {
        isRemindersEnabled = false
        appSettings.isRemindersEnabled = false
    }
}
