//
//  AppSettings.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 8/2/25.
//

import Foundation
import SwiftUI

@Observable
class AppSettings {
    let storage: UserDefaults

    init(storage: UserDefaults = UserDefaults.standard) {
        self.storage = storage
    }

    var nextCleaningHourOfDay: Int {
        get {
            getSetting(.nextCleaningHourOfDay) ?? 17
        }
        set {
            saveSetting(newValue, key: .nextCleaningHourOfDay)
        }
    }

    var nextCleaningDaysOut: Int {
        get {
            getSetting(.nextCleaningDaysOut) ?? 2
        }
        set {
            saveSetting(newValue, key: .nextCleaningDaysOut)
        }
    }

    var isAutoScheduleEnabled: Bool {
        get {
            getSetting(.isAutoScheduleEnabled) ?? true
        }
        set {
            saveSetting(newValue, key: .isAutoScheduleEnabled)
        }
    }

    var isNotificationsEnabled: Bool {
        get {
            getSetting(.isNotificationsEnabled) ?? false
        }
        set {
            saveSetting(newValue, key: .isNotificationsEnabled)
        }
    }

    var isRemindersEnabled: Bool {
        get {
            getSetting(.isRemindersEnabled) ?? false
        }
        set {
            saveSetting(newValue, key: .isRemindersEnabled)
        }
    }

    private func getSetting<T>(_ key: StorageKey) -> T? {
        storage.object(forKey: key.rawValue) as? T
    }

    private func saveSetting<T>(_ value: T, key: StorageKey) {
        storage.set(value, forKey: key.rawValue)
    }
}

extension AppSettings {
    private enum StorageKey: String {
        case isAutoScheduleEnabled = "appSetting-isAutoScheduleEnabled"
        case isNotificationsEnabled = "appSetting-isNotificationsEnabled"
        case isRemindersEnabled = "appSetting-isRemindersEnabled"
        case nextCleaningHourOfDay = "appSetting-nextCleaningHourOfDay"
        case nextCleaningDaysOut = "appSetting-nextCleaningDaysOut"
    }
}
