//
//  ConfirmView.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 2/2/25.
//

import SwiftUI

struct ConfirmView: View {
    @Environment(\.dependencies) private var dependencies: Dependencies

    @Environment(\.dismiss) private var dismiss

    @State private var completedDate = Date()

    @State private var scheduleNextCleaning = false

    @State var nextScheduleDate = Date()

    @State private var daysOut = 2

    @State private var hourOfDay = 17

    var confirmAction: ((Date, Date?) -> Void)

    var body: some View {
        VStack(spacing: 16) {
            DatePicker(selection: $completedDate) {}
                .labelsHidden()

            Divider()

            Toggle(isOn: $scheduleNextCleaning) {
                VStack(alignment: .leading) {
                    Text("Schedule next cleaning")
                        .font(.callout)
                }
            }

            if scheduleNextCleaning {
                VStack(alignment: .leading) {
                    Text(nextScheduleDate, format: .dateTime.weekday().month().day().hour())
                        .font(.headline)
                        .foregroundStyle(.secondary)


                    Stepper(value: $daysOut, in: 1...7) {
                        HStack {
                            Text("\(daysOut)")
                                .monospaced()

                            Text("days from now")
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)

                            Spacer()
                        }
                    }

                    Stepper(value: $hourOfDay, in: 0...23) {
                        HStack {
                            Text("at")
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)

                            Text("\(formatHour())")
                                .monospaced()
                        }
                    }
                }
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding()
        .navigationTitle("Mark Complete?")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(role: .cancel, action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                }
            }

            ToolbarItem(placement: .bottomBar) {
                Button(
                    role: .confirm,
                    action: {
                        updateNextScheduleDate()

                        confirmAction(
                            completedDate,
                            scheduleNextCleaning ? nextScheduleDate : nil
                        )

                        dismiss()
                }) {
                    HStack {
                        Image(systemName: "checkmark.square")
                        Text("Mark Complete")
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            scheduleNextCleaning = dependencies.appSettings.isAutoScheduleEnabled
            daysOut = dependencies.appSettings.nextCleaningDaysOut
            hourOfDay = dependencies.appSettings.nextCleaningHourOfDay
            updateNextScheduleDate()
        }
        .onChange(of: completedDate) { _, _ in
            updateNextScheduleDate()
        }
        .onChange(of: daysOut) { _, _ in
            updateNextScheduleDate()
        }
        .onChange(of: hourOfDay) { _, _ in
            updateNextScheduleDate()
        }
    }

    func updateNextScheduleDate() {
        let calendar = Calendar.current
        guard let completedDatePlusDays = calendar.date(byAdding: .day, value: daysOut, to: completedDate),
              let completedDatePlusDaysAndTime = calendar.date(
                bySettingHour: hourOfDay,
                minute: 0,
                second: 0,
                of: completedDatePlusDays
              ) else {
            nextScheduleDate = completedDate
            return
        }

        nextScheduleDate = completedDatePlusDaysAndTime
    }

    func formatHour() -> String {
        // FIXME: could potentially crash when springing forward for DST
        let date = Calendar.current.date(bySettingHour: hourOfDay, minute: 0, second: 0, of: Date())!
        return date.formatted(date: .omitted, time: .standard)
    }
}

#Preview {
    @Previewable @State var isPresented = true
    @Previewable @State var sheetContentHeight = CGFloat(0)

    VStack {
        Text("Content View")
    }
    .sheet(isPresented: $isPresented) {
        NavigationStack {
            ConfirmView() { _, _ in }
                .environment(\.dependencies, PreviewDependencies())
                .padding()
                .background {
                    GeometryReader { proxy in
                        Color.clear
                            .task {
                                sheetContentHeight = proxy.size.height
                            }
                    }
                }
                .presentationDetents([.medium])
        }
    }
}
