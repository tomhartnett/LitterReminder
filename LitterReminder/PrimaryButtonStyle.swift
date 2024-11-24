//
//  PrimaryButtonStyle.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 11/17/24.
//

import SwiftUI

struct PrimaryButtonStyle: PrimitiveButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.trigger()
        }) {
            configuration.label
                .font(.title3)
                .fontWeight(.bold)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
    }
}

#Preview {
    VStack(alignment: .leading) {
        Button(action: {}) {
            Text("Mark Complete")
        }
        .buttonStyle(PrimaryButtonStyle())

        Button(action: {}) {
            Text("Snooze 1 day")
        }
        .buttonStyle(PrimaryButtonStyle())

        Button(action: {}) {
            Text("Remind me in 2 days")
        }
        .buttonStyle(PrimaryButtonStyle())
    }
}
