//
//  Environment.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 8/17/25.
//

import SwiftUI

private struct DependenciesKey: EnvironmentKey {
    static let defaultValue: Dependencies = PreviewDependencies()
}

extension EnvironmentValues {
    var dependencies: Dependencies {
        get { self[DependenciesKey.self] }
        set { self[DependenciesKey.self] = newValue }
    }
}
