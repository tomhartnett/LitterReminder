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
        VStack {
            List {
                ForEach(viewModel.cleanings) { cleaning in
                    CleaningView(
                        model: .init(
                            currentDate: viewModel.currentDate,
                            scheduledDate: cleaning.scheduledDate,
                            completedDate: cleaning.completedDate
                        )
                    )
                }
                .onDelete { indexSet in
                    viewModel.delete(atOffsets: indexSet)
                }
            }
            .listStyle(.plain)

            if viewModel.cleanings.first(where: { !$0.isComplete }) == nil {
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
}

#Preview {
    ContentView(modelContext: previewContainer.mainContext)
}
