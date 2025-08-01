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
        VStack(alignment: .leading) {
            HStack(alignment: .center, spacing: 24) {
                Image(systemName: model.imageSystemName)
                    .font(.largeTitle)
                    .foregroundStyle(Color(uiColor: model.badgeColor), .primary)

                VStack(alignment: .leading) {
                    Text(model.title)
                        .font(.title2)

                    if let subtitle2 = model.subtitle2 {
                        Text(subtitle2)
                            .foregroundStyle(.secondary)
                            .font(.headline)
                    }

                    Text(model.subtitle1)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)

            if model.showDivider {
                Divider()
                    .padding(.leading)
                    .padding(.top)
            }
        }
    }
}

extension CleaningView {
    struct Model {
        let imageSystemName: String
        let badgeColor: UIColor
        let title: String
        let subtitle1: String
        let subtitle2: String?
        let showDivider: Bool

        init(
            imageSystemName: String,
            badgeColor: UIColor,
            title: String,
            subtitle1: String,
            subtitle2: String? = nil,
            showDivider: Bool = true
        ) {
            self.imageSystemName = imageSystemName
            self.badgeColor = badgeColor
            self.title = title
            self.subtitle1 = subtitle1
            self.subtitle2 = subtitle2
            self.showDivider = showDivider
        }

        init(
            currentDate: Date,
            scheduledDate: Date,
            completedDate: Date?,
            showDivider: Bool = true
        ) {
            if let completedDate {
                self.init(
                    imageSystemName: "clock.badge.checkmark",
                    badgeColor: .systemGreen,
                    title: completedDate.formattedString(),
                    subtitle1: completedDate.relativeFormattedString(),
                    showDivider: showDivider
                )
            } else if currentDate < scheduledDate {
                self.init(
                    imageSystemName: "clock",
                    badgeColor: .label,
                    title: "Cleaning scheduled",
                    subtitle1: scheduledDate.formattedString(),
                    subtitle2: scheduledDate.relativeFormattedString(),
                    showDivider: showDivider
                )
            } else {
                let elapsedTime = currentDate.timeIntervalSince(scheduledDate)
                if elapsedTime <= 3600 {
                    self.init(
                        imageSystemName: "clock.badge",
                        badgeColor: .systemOrange,
                        title: "Cleaning is due",
                        subtitle1: scheduledDate.formattedString(),
                        subtitle2: scheduledDate.relativeFormattedString(),
                        showDivider: showDivider
                    )
                } else {
                    self.init(
                        imageSystemName: "clock.badge.exclamationmark",
                        badgeColor: .systemRed,
                        title: "Cleaning is overdue",
                        subtitle1: scheduledDate.formattedString(),
                        subtitle2: scheduledDate.relativeFormattedString(),
                        showDivider: showDivider
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
