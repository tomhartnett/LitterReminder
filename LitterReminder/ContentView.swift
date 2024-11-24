//
//  ContentView.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 11/17/24.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @State private var viewModel: ViewModel

    var body: some View {
        VStack {
            List(viewModel.cleanings) { cleaning in
                CleaningView(cleaning: cleaning)
            }
            .listStyle(.plain)

            if viewModel.cleanings.isEmpty {
                Button(action: {
                    viewModel.addCleaning()
                }) {
                    Text("Schedule Cleaning")
                }
                .buttonStyle(PrimaryButtonStyle())
            } else {
                Button(action: {
                    viewModel.markComplete()
                    viewModel.addCleaning()
                }) {
                    Text("Mark Complete")
                }
                .buttonStyle(PrimaryButtonStyle())
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
