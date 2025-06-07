//
//  HistoryView.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 5/13/25.
//

import SwiftUI

struct HistoryView: View {
    @Environment(ViewModel.self) private var viewModel

    var body: some View {
        VStack {
            Group {
                if viewModel.hasCompletedCleanings {
                    listView
                } else {
                    noDataView
                }
            }
            .navigationTitle("History")
            .padding(.top)
        }
    }

    @ViewBuilder
    private var listView: some View {
        List {
            ForEach(viewModel.completedCleanings) { cleaning in
                CleaningView(
                    model: .init(
                        currentDate: viewModel.currentDate,
                        scheduledDate: cleaning.scheduledDate,
                        completedDate: cleaning.completedDate
                    )
                )
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        viewModel.delete(cleaning)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
    }

    @ViewBuilder
    private var noDataView: some View {
        ZStack {
            Text("No data")
                .font(.title)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    HistoryView()
        .environment(ViewModel(modelContext: previewContainer.mainContext))
}
