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

    var confirmAction: ((Date) -> Void)

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "clock.badge.checkmark")
                    .font(.largeTitle)
                    .foregroundStyle(Color(uiColor: .systemGreen), .primary)

                Text("Completed")
                    .font(.title)
            }
            .padding(.top)

            DatePicker(selection: $completedDate) {
                EmptyView()
            }
            .labelsHidden()

            Divider()

            HStack(spacing: 32) {
                Button(action: {
                    dismiss()
                }) {
                    Text("Cancel")
                }
                .buttonStyle(SecondaryButtonStyle())

                Button(action: {
                    dismiss()
                    confirmAction(completedDate)
                }) {
                    Text("Confirm")
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
        .padding(.horizontal, 32)
    }
}

#Preview {
    @Previewable @State var isPresented = true
    @Previewable @State var sheetContentHeight = CGFloat(0)

    VStack {
        Text("Content View")
    }
    .sheet(isPresented: $isPresented) {
        ConfirmView(confirmAction: { completedDate in })
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
