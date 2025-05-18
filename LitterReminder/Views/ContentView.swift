//
//  ContentView.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 11/17/24.
//

import SwiftData
import SwiftUI

enum AppNavigation {
    case history
}

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var viewModel: ViewModel
    @State private var showConfirmMarkComplete = false
    @State private var sheetContentHeight = CGFloat(0)
    @State private var navigation: AppNavigation?

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.hasScheduledCleaning || viewModel.hasCompletedCleanings {
                    listView
                } else {
                    noDataView
                }

                if viewModel.hasCompletedCleanings {
                    NavigationLink("History...", value: AppNavigation.history)
                        .font(.title)
                }

                actionButton
            }
            .padding(.top)
            .navigationTitle("Litter Reminder")
            .navigationDestination(for: AppNavigation.self, destination: { navigation in
                switch navigation {
                case .history:
                    HistoryView()
                        .environment(viewModel)
                }
            })
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

    @ViewBuilder
    private var listView: some View {
        List {
            if let lastCleaning = viewModel.completedCleanings.first,
               let completedDate = lastCleaning.completedDate {

                CleaningView(
                    model: .init(
                        imageSystemName: "clock.badge.checkmark",
                        badgeColor: .systemGreen,
                        title: "Last cleaning",
                        subtitle1: completedDate.formattedString(),
                        subtitle2: completedDate.relativeFormattedString()
                    )
                )
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        viewModel.delete(lastCleaning)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }

            if let cleaning = viewModel.scheduledCleaning {
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
        VStack {
            Spacer()

            Text("No data")
                .font(.title)
                .foregroundStyle(.secondary)

            Text("Tap \"Schedule Cleaning\" to get started")
                .foregroundStyle(.secondary)

            Spacer()
        }
    }
}

#Preview {
    ContentView(modelContext: previewContainer.mainContext)
}


