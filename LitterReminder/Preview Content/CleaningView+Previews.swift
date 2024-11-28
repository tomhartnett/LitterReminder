//
//  CleaningView+Previews.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 11/28/24.
//

import SwiftUI

extension CleaningView.Model {
    static let scheduledModel = CleaningView.Model(
        currentDate: .now,
        scheduledDate: .now.addingTimeInterval(3600 * 24 * 48),
        completedDate: nil
    )

    static let dueModel = CleaningView.Model(
        currentDate: .now,
        scheduledDate: .now.addingTimeInterval(-1800),
        completedDate: nil
    )

    static let overdueModel = CleaningView.Model(
        currentDate: .now,
        scheduledDate: .now.addingTimeInterval(-3601),
        completedDate: nil
    )

    static let completedModel = CleaningView.Model(
        currentDate: .now,
        scheduledDate: .now.addingTimeInterval(-3600 * 2),
        completedDate: .now.addingTimeInterval(-3600)
    )
}
