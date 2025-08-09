//
//  ContentView.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 11/17/24.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    var body: some View {
        HomeView()
    }
}

#Preview {
    ContentView()
        .environment(
            ViewModel(
                dependencies: PreviewDependencies()
            )
        )
        .environment(AppSettings())
}
