//
//  ContentView.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 11/17/24.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var viewModel: ViewModel
    @State private var showConfirmMarkComplete = false

    var body: some View {
        VStack(spacing: 0) {
            List {
                ForEach(viewModel.cleanings) { cleaning in
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
            .listStyle(.plain)

            VStack(spacing: 16) {
                Divider()

                actionButton
            }
            .frame(maxWidth: .infinity)
        }
        .onChange(of: scenePhase) { _, newValue in
            if newValue == .active {
                viewModel.fetchData()
                viewModel.updateCurrentDate()
                viewModel.requestRemindersAccess()
            }
        }
    }

    init(modelContext: ModelContext) {
        let viewModel = ViewModel(modelContext: modelContext)
        _viewModel = State(initialValue: viewModel)
    }

    @ViewBuilder
    private var actionButton: some View {
        if !viewModel.hasScheduledCleaning {
            Button(action: {
                withAnimation {
                    viewModel.addCleaning()
                }
            }) {
                Text("Schedule Cleaning")
            }
            .buttonStyle(PrimaryButtonStyle())
        } else {
            Button(action: {
                showConfirmMarkComplete.toggle()
            }) {
                Text("Mark Complete")
            }
            .buttonStyle(PrimaryButtonStyle())
            .confirmationDialog("Confirm", isPresented: $showConfirmMarkComplete) {
                Button("Mark Complete", role: .destructive) {
                    viewModel.markComplete()
                    withAnimation {
                        viewModel.addCleaning()
                    }
                }
                Button("Cancel", role: .cancel) { }
            }
        }
    }
}

#Preview {
    ContentView(modelContext: previewContainer.mainContext)
}
