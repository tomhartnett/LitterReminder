//
//  EditCleaningView.swift
//  LitterReminder
//

import SwiftUI

struct EditCleaningView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var scheduledDate: Date

    @State private var completedDate: Date

    private let isComplete: Bool

    private let saveAction: (Date, Date?) -> Void

    init(
        scheduledDate: Date,
        completedDate: Date?,
        saveAction: @escaping (Date, Date?) -> Void
    ) {
        _scheduledDate = State(initialValue: scheduledDate)
        _completedDate = State(initialValue: completedDate ?? .now)
        isComplete = completedDate != nil
        self.saveAction = saveAction
    }

    var body: some View {
        Form {
            Section("Scheduled") {
                DatePicker("Scheduled", selection: $scheduledDate)
            }

            if isComplete {
                Section("Completed") {
                    DatePicker("Completed", selection: $completedDate, in: ...Date.now)
                }
            }
        }
        .navigationTitle("Edit Cleaning")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(role: .cancel) {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button(role: .confirm) {
                    saveAction(scheduledDate, isComplete ? completedDate : nil)
                    dismiss()
                } label: {
                    Image(systemName: "checkmark")
                }
            }
        }
    }
}

#Preview("Completed") {
    NavigationStack {
        EditCleaningView(
            scheduledDate: .now.addingTimeInterval(-86_400),
            completedDate: .now
        ) { _, _ in }
    }
}

#Preview("Scheduled") {
    NavigationStack {
        EditCleaningView(
            scheduledDate: .now.addingTimeInterval(86_400),
            completedDate: nil
        ) { _, _ in }
    }
}
