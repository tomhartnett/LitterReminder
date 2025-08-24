//
//  SettingsView.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 8/1/25.
//

import SwiftUI
import UIKit

struct AlertDetails: Identifiable {
    let id = UUID()
    let message: String
    let showSettingsButton: Bool
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @Bindable var appSettings: AppSettings

    @State private var viewModel: SettingsViewModel

    @State private var nextCleaningDate = Date()

    init(appSettings: AppSettings, dependencies: Dependencies) {
        _viewModel = State(wrappedValue: SettingsViewModel(appSettings: appSettings, dependencies: dependencies))
        _appSettings = Bindable(appSettings)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Next cleaning schedule")
                .fontWeight(.medium)
                .fixedSize(horizontal: false, vertical: true)

            Stepper(value: $appSettings.nextCleaningDaysOut, in: 1...7) {
                HStack {
                    Text("\(appSettings.nextCleaningDaysOut)")
                        .monospaced()

                    Text("days from now")
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer()
                }
            }

            Stepper(value: $appSettings.nextCleaningHourOfDay, in: 0...23) {
                HStack {
                    Text("at")
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("\(formatHour())")
                        .monospaced()
                }
            }

            Text("Example from now: \(nextCleaningDate.formatted(.dateTime.weekday().month().day().hour()))")
                .font(.callout)
                .foregroundStyle(.secondary)

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
                isOn: .constant(viewModel.isNotificationsEnabled),
                label: String(localized: "Notifications"),
                attemptToEnable: {
                    Task {
                        await viewModel.enableNotifications()
                    }
                },
                attemptToDisable: { viewModel.disableNotifications() }
            )

            Text("A notification will be sent when it's time to clean the litter box.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Divider()

            PermissionToggle(
                isOn: .constant(viewModel.isRemindersEnabled),
                label: String(localized: "Reminders"),
                attemptToEnable: {
                    viewModel.enableReminders()
                },
                attemptToDisable: {
                    viewModel.disableReminders()
                }
            )

            Text("A reminder will be added to the Reminders app.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding()
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button(role: .confirm, action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle")
                        Text("Done")
                    }
                    .padding()
                }
            }
        }
        .alert(
            "Permission Needed",
            isPresented: .constant(viewModel.settingsAlert != nil),
            presenting: viewModel.settingsAlert,
            actions: { alertDetails in
                Button(role: .cancel, action: {
                    viewModel.settingsAlert = nil
                }) {
                    Text("Cancel")
                }

                if alertDetails.showSettingsButton {
                    Button(role: .confirm, action: {
                        viewModel.settingsAlert = nil
                        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                        UIApplication.shared.open(url)
                    }) {
                        Text("Settings")
                    }
                }
            },
            message: { details in
                Text(details.message)
            }
        )
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
        // FIXME: could potentially crash when springing forward for DST
        let dateWithHour = calendar.date(bySettingHour: appSettings.nextCleaningHourOfDay, minute: 0, second: 0, of: date)!
        nextCleaningDate = dateWithHour
    }

    func formatHour() -> String {
        // FIXME: could potentially crash when springing forward for DST
        let date = Calendar.current.date(bySettingHour: appSettings.nextCleaningHourOfDay, minute: 0, second: 0, of: Date())!
        return date.formatted(date: .omitted, time: .standard)
    }
}

#Preview {
    NavigationStack {
        SettingsView(appSettings: AppSettings(), dependencies: PreviewDependencies())
    }
}
