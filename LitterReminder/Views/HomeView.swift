//
//  HomeView.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 5/18/25.
//

import SwiftUI

struct HomeView: View {
    @Environment(ViewModel.self) private var viewModel
    @State private var showConfirmMarkComplete = false
    @State private var sheetContentHeight = CGFloat(0)

    var body: some View {
        VStack {
            if viewModel.hasScheduledCleaning || viewModel.hasCompletedCleanings {
                listView
            } else {
                noDataView
            }

            actionButton
                .padding(.bottom)
        }
        .padding(.top)
        .navigationTitle("Litter Reminder")
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil), actions: {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        }, message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            } else {
                Text("An unknown error has occurred.")
            }
        })
        .sheet(isPresented: $showConfirmMarkComplete) {
            ConfirmView(confirmAction: { completedDate in
                withAnimation {
                    viewModel.addCleaning(completedDate)
                    viewModel.markComplete(completedDate)
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
    }

    @ViewBuilder
    private var actionButton: some View {
        if !viewModel.hasScheduledCleaning {
            Button(action: {
                Task {
                    withAnimation {
                        viewModel.addCleaning()
                    }
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
    HomeView()
        .environment(
            ViewModel(
                dependencies: AppDependencies(), // TODO: mock/preview dependencies
                modelContext: previewContainer.mainContext
            )
        )
}
