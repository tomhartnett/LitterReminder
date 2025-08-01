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

            Divider()

            actionButton
                .padding(.vertical)
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
        .sheet(isPresented: $showConfirmMarkComplete) {
            ConfirmView(confirmAction: { completedDate in
                withAnimation {
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
}

#Preview {
    HomeView()
        .environment(
            ViewModel(
                dependencies: PreviewDependencies()
            )
        )
}
