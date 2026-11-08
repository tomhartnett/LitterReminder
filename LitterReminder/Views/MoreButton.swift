//
//  MoreButton.swift
//  LitterReminder
//

import SwiftUI

struct MoreButton: View {
    var addPastCleaningAction: () -> Void

    var settingsAction: () -> Void

    var body: some View {
        Menu {
            Button(action: settingsAction) {
                Label("Settings", systemImage: "gearshape")
            }

            Divider()

            Button(action: addPastCleaningAction) {
                Label("Add past cleaning...", systemImage: "clock.arrow.circlepath")
            }
        } label: {
            Image(systemName: "ellipsis")
        }
        .accessibilityLabel("More")
    }
}

#Preview {
    MoreButton(addPastCleaningAction: {}, settingsAction: {})
}
