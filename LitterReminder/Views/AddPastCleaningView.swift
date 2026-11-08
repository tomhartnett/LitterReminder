//
//  AddPastCleaningView.swift
//  LitterReminder
//

import SwiftUI

struct AddPastCleaningView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var completedDate = Date.now.addingTimeInterval(-86_400)

    var saveAction: (Date) -> Void

    var body: some View {
        Form {
            Section {
                DatePicker("Completed", selection: $completedDate, in: ...Date.now)
            } footer: {
                Text("Record a cleaning that was done but not entered.")
            }
        }
        .navigationTitle("Add Past Cleaning")
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
                    saveAction(completedDate)
                    dismiss()
                } label: {
                    Image(systemName: "checkmark")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AddPastCleaningView { _ in }
    }
}
