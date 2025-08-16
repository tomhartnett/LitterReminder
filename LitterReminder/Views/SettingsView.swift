//
//  SettingsView.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 8/1/25.
//

import SwiftUI
import UIKit

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @Bindable var appSettings: AppSettings

    @State private var nextCleaningDate = Date()

    @State private var isNotificationsEnabled = false

    @State private var showNotificationsAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Schedule Settings")
                    .fontWeight(.medium)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()

                Text(nextCleaningDate, format: .dateTime.weekday().month().day().hour())
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Stepper(value: $appSettings.nextCleaningDaysOut, in: 1...7) {
                HStack {
                    Text("Days from now:")
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer()

                    Text("\(appSettings.nextCleaningDaysOut)")
                        .monospaced()
                }
            }

            Stepper(value: $appSettings.nextCleaningHourOfDay, in: 0...23) {
                HStack {
                    Text("Time of day:")
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer()

                    Text("\(formatHour())")
                        .monospaced()
                }
            }

            Divider()

            Toggle(isOn: $appSettings.isAutoScheduleEnabled) {
                Text("Automatic scheduling")
                    .fontWeight(.medium)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Text("Automatically schedule the next cleaning when one is marked complete.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Divider()

            PermissionToggle(
                isOn: $isNotificationsEnabled,
                label: "Notifications",
                attemptToEnable: {
                    Task {
                        await enableNotifications()
                    }
                },
                attemptToDisable: { disableNotifications() }
            )

            Text("A notification will be sent when it's time to clean the litter box.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Divider()

            Toggle(isOn: $appSettings.isRemindersEnabled) {
                Text("Reminders")
                    .fontWeight(.medium)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Text("A reminder will be added to the Reminders app.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding()
        .toolbar {
            ToolbarSpacer(.flexible, placement: .topBarTrailing)
            ToolbarItem(placement: .primaryAction) {
                Button(role: .confirm, action: {
                    dismiss()
                }) {
                    Image(systemName: "checkmark")
                }
            }
        }
        .alert(
            "Allow Notifications",
            isPresented: $showNotificationsAlert,
            actions: {
                Button(role: .cancel, action: {}) {
                    Text("Cancel")
                }

                Button(role: .confirm, action: {
                    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                    UIApplication.shared.open(url)
                }) {
                    Text("Settings")
                }
            }, message: {
                Text("Notifications are not allowed. Open Settings to allow.")
            }
        )
        .onAppear {
            buildDate()

            isNotificationsEnabled = appSettings.isNotificationsEnabled
        }
        .onChange(of: appSettings.nextCleaningDaysOut) { _, _ in
            buildDate()
        }
        .onChange(of: appSettings.nextCleaningHourOfDay) { _, _ in
            buildDate()
        }
    }

    func buildDate() {
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .day, value: appSettings.nextCleaningDaysOut, to: Date())!
        let dateWithHour = calendar.date(bySettingHour: appSettings.nextCleaningHourOfDay, minute: 0, second: 0, of: date)!
        nextCleaningDate = dateWithHour
    }

    func formatHour() -> String {
        let date = Calendar.current.date(bySettingHour: appSettings.nextCleaningHourOfDay, minute: 0, second: 0, of: Date())!
        return date.formatted(date: .omitted, time: .standard)
    }

    func enableNotifications() async {
        isNotificationsEnabled = true
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .notDetermined:
            do {
                let authorized = try await center.requestAuthorization(options: [.alert, .badge, .sound])
                isNotificationsEnabled = authorized
                appSettings.isNotificationsEnabled = authorized
            } catch {
                isNotificationsEnabled = false
            }
        case .denied:
            showNotificationsAlert = true
            isNotificationsEnabled = false
        case .authorized, .provisional, .ephemeral:
            appSettings.isNotificationsEnabled = true
        @unknown default:
            break
        }
    }

    func disableNotifications() {
        isNotificationsEnabled = false
        appSettings.isNotificationsEnabled = false
    }
}

#Preview {
    SettingsView(appSettings: AppSettings())
}
