//
//  CleaningView.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 11/17/24.
//

import SwiftUI

enum CleaningStatus {
    case scheduled
    case due
    case completed
    case overdue

    var imageSystemName: String {
        switch self {
        case .scheduled:
            return "clock"
        case .due:
            return "clock.badge"
        case .completed:
            return "clock.badge.checkmark"
        case .overdue:
            return "clock.badge.exclamationmark"
        }
    }

    var title: String {
        switch self {
        case .scheduled:
            return "Cleaning scheduled"
        case .due:
            return "Cleaning is due"
        case .completed:
            return "Cleaning completed"
        case .overdue:
            return "Cleaning is overdue!"
        }
    }

    var badgeColor: Color {
        switch self {
        case .scheduled:
            return .primary
        case .due:
            return .red
        case .completed:
            return .green
        case .overdue:
            return .orange
        }
    }
}

struct CleaningView: View {
    var cleaning: Cleaning

    var body: some View {
        HStack(spacing: 24) {
            Image(systemName: cleaning.status().imageSystemName)
                .imageScale(.large)
                .font(.title)
                .symbolRenderingMode(.palette)
                .foregroundStyle(cleaning.status().badgeColor, .primary)

            VStack(alignment: .leading) {
                Text(cleaning.status().title)
                    .font(.title)

                if let completedDate = cleaning.completedDate {
                    Text(completedDate, format: .dateTime)
                } else {
                    Text(AppDateFormatter.dateDisplayText(for: cleaning.scheduledDate))
                }
            }
        }

        .padding()
    }
}

#Preview {
    VStack(alignment: .leading) {
        CleaningView(cleaning: Cleaning(createdDate: .now, scheduledDate: .now.addingTimeInterval(3600 * 48)))
        CleaningView(cleaning: Cleaning(createdDate: .now, scheduledDate: .now.addingTimeInterval(-1800)))
        CleaningView(cleaning: Cleaning(createdDate: .now, scheduledDate: .now.addingTimeInterval(-3601)))
        CleaningView(
            cleaning: Cleaning(
                createdDate: .now,
                scheduledDate: .now.addingTimeInterval(-3601),
                completedDate: .now
            )
        )
    }
}
