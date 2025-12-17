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
        self.nextCleaningHourOfDay = storage.object(forKey: StorageKey.nextCleaningHourOfDay.rawValue) as? Int ?? 17
        self.nextCleaningDaysOut = storage.object(forKey: StorageKey.nextCleaningDaysOut.rawValue) as? Int ?? 2
        self.isAutoScheduleEnabled = storage.object(forKey: StorageKey.isAutoScheduleEnabled.rawValue) as? Bool ?? true
        self.isNotificationsEnabled = storage.object(forKey: StorageKey.isNotificationsEnabled.rawValue) as? Bool ?? false
        self.isRemindersEnabled = storage.object(forKey: StorageKey.isRemindersEnabled.rawValue) as? Bool ?? false
    }

    var nextCleaningHourOfDay: Int {
        didSet {
            storage.set(nextCleaningHourOfDay, forKey: StorageKey.nextCleaningHourOfDay.rawValue)
        }
    }

    var nextCleaningDaysOut: Int {
        didSet {
            storage.set(nextCleaningDaysOut, forKey: StorageKey.nextCleaningDaysOut.rawValue)
        }
    }

    var isAutoScheduleEnabled: Bool {
        didSet {
            storage.set(isAutoScheduleEnabled, forKey: StorageKey.isAutoScheduleEnabled.rawValue)
        }
    }

    var isNotificationsEnabled: Bool {
        didSet {
            storage.set(isNotificationsEnabled, forKey: StorageKey.isNotificationsEnabled.rawValue)
        }
    }

    var isRemindersEnabled: Bool {
        didSet {
            storage.set(isRemindersEnabled, forKey: StorageKey.isRemindersEnabled.rawValue)
        }
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
