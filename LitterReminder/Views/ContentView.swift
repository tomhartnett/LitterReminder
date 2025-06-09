//
//  ContentView.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 11/17/24.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(ViewModel.self) private var viewModel
    @State private var showConfirmMarkComplete = false
    @State private var sheetContentHeight = CGFloat(0)

    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                HomeView()
                    .environment(viewModel)
            }

            Tab("History", systemImage: "calendar") {
                HistoryView()
                    .environment(viewModel)
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(
            ViewModel(
                dependencies: AppDependencies(), // TODO: mock/preview dependencies
                modelContext: previewContainer.mainContext
            )
        )
}


