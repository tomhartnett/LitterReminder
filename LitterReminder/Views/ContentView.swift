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
    @State private var sheetContentHeight = CGFloat(0)

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
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
                .listStyle(.plain)
            }

            if let cleaning = viewModel.scheduledCleaning {
                Divider()

                CleaningView(
                    model: CleaningView.Model(
                        currentDate: viewModel.currentDate,
                        scheduledDate: cleaning.scheduledDate,
                        completedDate: cleaning.completedDate
                    )
                )
            } else {
                Divider()
                    .padding(.bottom)
            }

            actionButton
        }
        .sheet(isPresented: $showConfirmMarkComplete) {
            ConfirmView(confirmAction: { completedDate in
                withAnimation {
                    viewModel.markComplete(completedDate)
                    viewModel.addCleaning(completedDate)
                }
            })
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
        }
    }
}

#Preview {
    ContentView(modelContext: previewContainer.mainContext)
}
