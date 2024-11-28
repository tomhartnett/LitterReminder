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
}

struct CleaningView: View {
    var model: Model

    var body: some View {
        HStack(spacing: 24) {
            Image(systemName: model.imageSystemName)
                .font(.largeTitle)
                .foregroundStyle(Color(uiColor: model.badgeColor), .primary)

            VStack(alignment: .leading) {
                Text(model.title)
                    .font(.title)

                Text(model.subtitle)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
}

extension CleaningView {
    struct Model {
        let imageSystemName: String
        let badgeColor: UIColor
        let title: String
        let subtitle: String

        init(
            imageSystemName: String,
            badgeColor: UIColor,
            title: String,
            subtitle: String
        ) {
            self.imageSystemName = imageSystemName
            self.badgeColor = badgeColor
            self.title = title
            self.subtitle = subtitle
        }

        init(
            currentDate: Date,
            scheduledDate: Date,
            completedDate: Date?
        ) {
            if let completedDate {
                self.init(
                    imageSystemName: "clock.badge.checkmark",
                    badgeColor: .systemGreen,
                    title: "Cleaning completed",
                    subtitle: AppDateFormatter.completedDateDisplayText(completedDate)
                )
            } else if currentDate < scheduledDate {
                self.init(
                    imageSystemName: "clock",
                    badgeColor: .label,
                    title: "Cleaning scheduled",
                    subtitle: AppDateFormatter.scheduledDateDisplayText(for: scheduledDate)
                )
            } else {
                let elapsedTime = currentDate.timeIntervalSince(scheduledDate)
                if elapsedTime <= 3600 {
                    self.init(
                        imageSystemName: "clock.badge",
                        badgeColor: .systemRed,
                        title: "Cleaning is due",
                        subtitle: AppDateFormatter.scheduledDateDisplayText(for: scheduledDate)
                    )
                } else {
                    self.init(
                        imageSystemName: "clock.badge.exclamationmark",
                        badgeColor: .systemOrange,
                        title: "Cleaning is overdue",
                        subtitle: AppDateFormatter.scheduledDateDisplayText(for: scheduledDate)
                    )
                }
            }
        }
    }
}

#Preview {
    List {
        CleaningView(model: .scheduledModel)
        CleaningView(model: .dueModel)
        CleaningView(model: .overdueModel)
        CleaningView(model: .completedModel)
    }
}
