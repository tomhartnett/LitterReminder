//
//  SettingsView.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 8/1/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @Bindable var appSettings: AppSettings

    @State private var nextCleaningDate = Date()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Schedule Settings")
                    .fontWeight(.medium)

                Spacer()

                Text(nextCleaningDate, format: .dateTime.weekday().month().day().hour())
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            Stepper(value: $appSettings.nextCleaningDaysOut, in: 1...7) {
                HStack {
                    Text("Days from now:")
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text("\(appSettings.nextCleaningDaysOut)")
                        .monospaced()
                }
            }

            Stepper(value: $appSettings.nextCleaningHourOfDay, in: 0...23) {
                HStack {
                    Text("Time of day:")
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text("\(formatHour())")
                        .monospaced()
                }
            }

            Divider()

            Toggle(isOn: $appSettings.isNotificationsEnabled) {
                Text("Send me a notification")
                    .fontWeight(.medium)
            }

            Text("A notification will be sent when it's time to clean the litter box.")
                .font(.callout)
                .foregroundStyle(.secondary)

            Divider()

            Toggle(isOn: $appSettings.isRemindersEnabled) {
                Text("Add to Reminders app")
                    .fontWeight(.medium)
            }

            Text("A reminder will be added to the Reminders app.")
                .font(.callout)
                .foregroundStyle(.secondary)
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
        .onAppear {
            buildDate()
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
}

#Preview {
    SettingsView(appSettings: AppSettings())
}
