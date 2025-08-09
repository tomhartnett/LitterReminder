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
        loadSettings()
    }

    var nextCleaningHourOfDay: Int = 0 {
        didSet {
            saveSetting(nextCleaningHourOfDay, key: .nextCleaningHourOfDay)
        }
    }

    var nextCleaningDaysOut: Int = 0 {
        didSet {
            saveSetting(nextCleaningDaysOut, key: .nextCleaningDaysOut)
        }
    }

    var isNotificationsEnabled: Bool = false {
        didSet {
            saveSetting(isNotificationsEnabled, key: .isNotificationsEnabled)
        }
    }

    var isRemindersEnabled: Bool = false {
        didSet {
            saveSetting(isRemindersEnabled, key: .isRemindersEnabled)
        }
    }

    private func loadSettings() {
        isNotificationsEnabled = getSetting(.isNotificationsEnabled) ?? false
        isRemindersEnabled = getSetting(.isRemindersEnabled) ?? false
        nextCleaningHourOfDay = getSetting(.nextCleaningHourOfDay) ?? 17
        nextCleaningDaysOut = getSetting(.nextCleaningDaysOut) ?? 2
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
        case nextCleaningHourOfDay = "appSetting-nextCleaningHourOfDay"
        case nextCleaningDaysOut = "appSetting-nextCleaningDaysOut"
        case isNotificationsEnabled = "appSetting-isNotificationsEnabled"
        case isRemindersEnabled = "appSetting-isRemindersEnabled"
    }
}
