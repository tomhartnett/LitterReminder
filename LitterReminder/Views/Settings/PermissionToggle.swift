//
//  PermissionToggle.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 8/15/25.
//

import SwiftUI

struct PermissionToggle: View {
    @Binding var isOn: Bool

    var label: String

    var attemptToEnable: (() -> Void)

    var attemptToDisable: (() -> Void)

    var body: some View {
        Toggle(isOn: Binding(get: {
            isOn
        }, set: { newValue in
            if newValue {
                attemptToEnable()
            } else {
                attemptToDisable()
            }
        })) {
            Text(label)
                .fontWeight(.medium)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    @Previewable @State var isOn = true

    PermissionToggle(
        isOn: $isOn,
        label: "Notifications",
        attemptToEnable: { isOn = true },
        attemptToDisable: { isOn = false }
    )
}
