//
//  HistoryChartView.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 7/19/25.
//

import Charts
import Playgrounds
import SwiftUI

struct CleaningPoint: Identifiable {
    let id: String
    let date: Date
    let color: Color
}

struct HistoryChartView: View {
    var model: Model

    var body: some View {
        Chart {
            ForEach(model.points) { point in
                PointMark(
                    x: .value("Date", point.date, unit: .day),
                    y: .value("Time", 1)
                )
                .foregroundStyle(point.color)
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(centered: true) {
                    if let date = value.as(Date.self) {
                        // TODO: how to handle very large text sizes without truncating.
                        VStack {
                            Text(date.formatted(.dateTime.weekday(.narrow)))
                            Text(date.formatted(.dateTime.day(.defaultDigits)))
                        }
                        .fontWeight(Calendar.current.isDateInToday(date) ? .bold : .regular)
                        .foregroundStyle(Calendar.current.isDateInToday(date) ? .red : .secondary)
                    }
                }
            }
        }
        .chartYAxis(.hidden)
        .chartXScale(domain: [model.startDate, model.endDate])
        .chartYScale(domain: [0, 2])
    }
}

extension HistoryChartView {
    struct Model {
        let points: [CleaningPoint]
        let startDate: Date
        let endDate: Date

        init(
            points: [CleaningPoint],
            startDate: Date,
            endDate: Date
        ) {
            self.points = points
            self.startDate = startDate
            self.endDate = endDate
        }

        init(_ cleanings: [Cleaning], currentDate: Date, totalDays: Int = 14) {
            let calendar = Calendar.current
            let startOfToday = calendar.startOfDay(for: currentDate)
            let twoDaysFromNow = calendar.date(byAdding: .day, value: 2, to: startOfToday)!

            let endDate: Date
            if let nextCleaning = cleanings
                .filter({ !$0.isComplete })
                .sorted(by: { $0.scheduledDate < $1.scheduledDate })
                .last {
                endDate = calendar.startOfDay(
                    for: max(nextCleaning.scheduledDate, twoDaysFromNow)
                )
            } else {
                endDate = twoDaysFromNow
            }

            let startDate = calendar.startOfDay(
                for: calendar.date(byAdding: .day, value: -totalDays, to: endDate)!
            )

            self.points = cleanings
                .filter({ $0.scheduledDate >= startDate })
                .map({ CleaningPoint($0, currentDate: currentDate) })

            print("🍕 \(startDate)–\(endDate)")

            self.startDate = startDate
            self.endDate = calendar.date(byAdding: .day, value: 1, to: endDate)!
        }
    }
}

extension CleaningPoint {
    init(_ cleaning: Cleaning, currentDate: Date) {
        let date = cleaning.completedDate ?? cleaning.scheduledDate

        let color: Color
        if cleaning.isComplete {
            color = Color(uiColor: .systemGreen)
        } else {
            let timeUntilDue = currentDate.timeIntervalSince(cleaning.scheduledDate)
            switch timeUntilDue {
            case 0..<3600:
                color = Color(uiColor: .systemOrange)

            case 3600...:
                color = Color(uiColor: .systemRed)

            case ..<0:
                fallthrough

            default:
                color = Color(uiColor: .systemGray)
            }
        }

        self.init(
            id: cleaning.identifier,
            date: date,
            color: color
        )
    }
}

extension Date {
    init(_ yyyyMMdd_HHmm: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        self = formatter.date(from: yyyyMMdd_HHmm) ?? Date()
    }
}

#Preview {
    HistoryChartView(
        model: .init(
            points: [
                CleaningPoint(id: UUID().uuidString, date: Date("2025/07/20 17:00"), color: .red),
                CleaningPoint(id: UUID().uuidString, date: Date("2025/07/18 17:50"), color: .orange),
                CleaningPoint(id: UUID().uuidString, date: Date("2025/07/15 19:14"), color: .gray),
                CleaningPoint(id: UUID().uuidString, date: Date("2025/07/10 19:54"), color: .green),
                CleaningPoint(id: UUID().uuidString, date: Date("2025/07/09 09:22"), color: .green),
                CleaningPoint(id: UUID().uuidString, date: Date("2025/06/30 18:59"), color: .green),
                CleaningPoint(id: UUID().uuidString, date: Date("2025/06/27 19:34"), color: .green),
                CleaningPoint(id: UUID().uuidString, date: Date("2025/06/24 20:31"), color: .green)
            ],
            startDate: Date("2025/07/10 00:00"),
            endDate: Date("2025/07/26 00:00")
        )
    )
}
