//
//  ConfirmView.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 2/2/25.
//

import SwiftUI

struct ConfirmView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var completedDate = Date()

    @State private var scheduleNextCleaning = true

    var confirmAction: ((Date, Bool) -> Void)

    var nextScheduleDateFromNow: Date

    var isAutoSchedulingEnabled: Bool

    var body: some View {
        VStack(spacing: 16) {
            DatePicker(selection: $completedDate) {
            }
            .labelsHidden()

            Divider()

            Toggle(isOn: $scheduleNextCleaning) {
                VStack(alignment: .leading) {
                    Text("Schedule next cleaning")
                        .font(.callout)
                    Text(nextScheduleDateFromNow, format: .dateTime.weekday().month().day().hour())
                        .foregroundStyle(.secondary)
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

            ToolbarItem(placement: .primaryAction) {
                Button(role: .confirm, action: {
                    dismiss()
                    confirmAction(completedDate, scheduleNextCleaning)
                }) {
                    Image(systemName: "checkmark")
                }
            }
        }
        .onAppear {
            scheduleNextCleaning = isAutoSchedulingEnabled
        }
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
            ConfirmView(confirmAction: { completedDate, scheduleNextCleaning in },
                        nextScheduleDateFromNow: Date().addingTimeInterval(86_400 * 2),
                        isAutoSchedulingEnabled: true)
                .padding()
                .background {
                    GeometryReader { proxy in
                        Color.clear
                            .task {
                                sheetContentHeight = proxy.size.height
                            }
                    }
                }
                .presentationDetents([.height(sheetContentHeight)])
        }
    }
}
