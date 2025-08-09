//
//  HomeView.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 5/18/25.
//

import SwiftUI

enum HomeViewSheet: Identifiable {
    case confirmMarkComplete
    case settings

    var id: Self {
        self
    }
}

struct HomeView: View {
    @Environment(AppSettings.self) private var appSettings
    @Environment(ViewModel.self) private var viewModel
    @State private var sheet: HomeViewSheet?
    @State private var sheetContentHeight = CGFloat(0)

    var body: some View {
        VStack {
            HistoryChartView(model: .init(viewModel.cleanings, currentDate: viewModel.currentDate))
                .frame(height: 50)
                .padding(.horizontal)

            Divider()

            ScrollViewReader { proxy in
                List {
                    ForEach(Array(viewModel.reversedCleanings.enumerated()), id: \.element.identifier) { index, item in
                        CleaningView(
                            model: .init(
                                currentDate: viewModel.currentDate,
                                scheduledDate: item.scheduledDate,
                                completedDate: item.completedDate,
                                showDivider: index != viewModel.reversedCleanings.count - 1
                            )
                        )
                        .id(index)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                viewModel.delete(item)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .listRowSeparator(
                            // Possibly a iOS 26 beta bug. Last item shows a separator beneath it.
                            // Hiding this and implementing custom divider instead (`showDivider` above).
                            .hidden
                        )
                    }
                }
                .onAppear {
                    scrollToBottom(proxy: proxy)
                }
                .onChange(of: viewModel.reversedCleanings.count) { _, _ in
                    scrollToBottom(proxy: proxy)
                }
            }
        }
        .listStyle(.plain)
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
        .sheet(item: $sheet) { item in
            switch item {
            case .confirmMarkComplete:
                confirmSheet

            case .settings:
                settingsSheet
            }
        }
        .toolbar {
            ToolbarSpacer(.flexible, placement: .bottomBar)

            ToolbarItem(placement: .bottomBar) {
                actionButton
            }

            ToolbarSpacer(.flexible, placement: .bottomBar)

            ToolbarItem(placement: .bottomBar) {
                Button(action: {
                    sheet = .settings
                }) {
                    Image(systemName: "gearshape")
                }
            }
        }
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        let count = viewModel.reversedCleanings.count
        if count > 0 {
            withAnimation(.easeOut(duration: 0.3)) {
                proxy.scrollTo(count - 1, anchor: .bottom)
            }
        }
    }

    @ViewBuilder
    private var actionButton: some View {
        if !viewModel.hasScheduledCleaning {
            Button(role: .confirm, action: {
                Task {
                    withAnimation {
                        viewModel.addCleaning()
                    }
                }
            }) {
                HStack {
                    Image(systemName: "calendar.badge.clock")
                    Text("Schedule")
                }
                .padding()
            }

        } else {
            Button(role: .confirm, action: {
                sheet = .confirmMarkComplete
            }) {
                HStack {
                    Image(systemName: "checkmark.square")
                    Text("Mark Complete")
                }
            }

        }
    }

    @ViewBuilder
    private var confirmSheet: some View {
        NavigationStack {
            ConfirmView(
                confirmAction: { completedDate, scheduleNextCleaning in
                    withAnimation {
                        viewModel.markComplete(completedDate, scheduleNextCleaning: scheduleNextCleaning)
                    }
                },
                nextScheduleDateFromNow: viewModel.nextScheduleDateFromNow,
                isAutoSchedulingEnabled: appSettings.isAutoScheduleEnabled
            )
            .presentationDetents([.medium])
        }
    }

    @ViewBuilder
    private var settingsSheet: some View {
        NavigationStack {
            SettingsView(appSettings: appSettings)
        }
    }
}

#Preview {
    HomeView()
        .environment(
            ViewModel(
                dependencies: PreviewDependencies()
            )
        )
        .environment(AppSettings())
}
