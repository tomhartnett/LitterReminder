//
//  HistoryView.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 5/13/25.
//

import SwiftUI

struct HistoryView: View {
    var currentDate: Date
    var cleanings: [Cleaning]

    var body: some View {
        List {
            ForEach(cleanings) { cleaning in
                CleaningView(
                    model: .init(
                        currentDate: currentDate,
                        scheduledDate: cleaning.scheduledDate,
                        completedDate: cleaning.completedDate
                    )
                )
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle("History")
        .padding(.top)
    }
}

#Preview {
    HistoryView(currentDate: .now,
                cleanings: [])
}
