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
    let secondsSinceMidnight: Double
    let isComplete: Bool
    let isOverdue: Bool
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
                .foregroundStyle(pointColor(point))
            }
        }
        .chartYAxis(.hidden)
        .chartYScale(domain: [0, 2])
    }

    func pointColor(_ point: CleaningPoint) -> Color {
        if point.isComplete {
            return .green
        } else if point.isOverdue {
            return .orange
        } else {
            return .gray
        }
    }
}

extension HistoryChartView {
    struct Model {
        let points: [CleaningPoint]
        let yAxisMin: Double
        let yAxisMax: Double

        var yAxisValues: [Double] {
            let values: [Double] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23]
            return values.filter({ ($0 * 3600) >= yAxisMin && ($0 * 3600) < yAxisMax }).map({ $0 * 3600 })
        }

        init(points: [CleaningPoint], yAxisMin: Double, yAxisMax: Double) {
            self.points = points
            self.yAxisMin = yAxisMin
            self.yAxisMax = yAxisMax
        }

        init(_ cleanings: [Cleaning]) {
            let points = cleanings.map({ CleaningPoint($0) })
            let sortedPoints = points.sorted(by: { $0.secondsSinceMidnight < $1.secondsSinceMidnight })

            self.points = points
            self.yAxisMin = sortedPoints.first?.secondsSinceMidnight ?? 0
            self.yAxisMax = sortedPoints.last?.secondsSinceMidnight ?? 0
        }
    }
}

extension CleaningPoint {
    init(_ cleaning: Cleaning) {
        let date = cleaning.completedDate ?? cleaning.scheduledDate
        let secondsSinceMidnight = date.timeIntervalSince(Calendar.current.startOfDay(for: date))
        self.init(
            id: cleaning.identifier,
            date: date,
            secondsSinceMidnight: secondsSinceMidnight,
            isComplete: cleaning.isComplete,
            isOverdue: cleaning.isOverdue()
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

//#Playground {
//    let point1 = CleaningPoint(
//        Cleaning(
//            createdDate: Date().addingTimeInterval(-25_000),
//            scheduledDate: Date().addingTimeInterval(45_000),
//            completedDate: Date().addingTimeInterval(35_000)
//        )
//    )
//
//    let point2 = CleaningPoint(
//        Cleaning(
//            createdDate: Date().addingTimeInterval(-45_000),
//            scheduledDate: Date().addingTimeInterval(45_000),
//            completedDate: nil
//        )
//    )
//}

#Preview {
    HistoryChartView(
        model: .init(
            points: [
                CleaningPoint(id: UUID().uuidString, date: .init("2025/07/20 17:00"), secondsSinceMidnight: 61200, isComplete: false, isOverdue: false),
                CleaningPoint(id: UUID().uuidString, date: .init("2025/07/18 17:50"), secondsSinceMidnight: 64200, isComplete: true, isOverdue: true),
                CleaningPoint(id: UUID().uuidString, date: .init("2025/07/15 19:14"), secondsSinceMidnight: 69240, isComplete: true, isOverdue: true),
                CleaningPoint(id: UUID().uuidString, date: .init("2025/07/12 19:54"), secondsSinceMidnight: 71640, isComplete: true, isOverdue: true),
                CleaningPoint(id: UUID().uuidString, date: .init("2025/07/09 09:22"), secondsSinceMidnight: 33720, isComplete: true, isOverdue: true),
                CleaningPoint(id: UUID().uuidString, date: .init("2025/06/30 18:59"), secondsSinceMidnight: 68340, isComplete: true, isOverdue: true),
                CleaningPoint(id: UUID().uuidString, date: .init("2025/06/27 19:34"), secondsSinceMidnight: 70440, isComplete: true, isOverdue: true),
                CleaningPoint(id: UUID().uuidString, date: .init("2025/06/24 20:31"), secondsSinceMidnight: 73860, isComplete: true, isOverdue: true)
            ],
            yAxisMin: 61200,
            yAxisMax: 73860
        )
    )
}

/*
 CleaningPoint(id: UUID().uuidString, date: .init("2025/07/20 17:00"), minutesSinceMidnight: 1070, isComplete: false),
 CleaningPoint(id: UUID().uuidString, date: .init("2025/07/18 17:50"), minutesSinceMidnight: 1070, isComplete: true),
 CleaningPoint(id: UUID().uuidString, date: .init("2025/07/15 19:14"), minutesSinceMidnight: 1154, isComplete: true),
 CleaningPoint(id: UUID().uuidString, date: .init("2025/07/12 19:54"), minutesSinceMidnight: 1194, isComplete: true),
 CleaningPoint(id: UUID().uuidString, date: .init("2025/07/09 09:22"), minutesSinceMidnight: 562, isComplete: true),
 CleaningPoint(id: UUID().uuidString, date: .init("2025/06/30 18:59"), minutesSinceMidnight: 1139, isComplete: true),
 CleaningPoint(id: UUID().uuidString, date: .init("2025/06/27 19:34"), minutesSinceMidnight: 1174, isComplete: true),
 CleaningPoint(id: UUID().uuidString, date: .init("2025/06/24 20:31"), minutesSinceMidnight: 1231, isComplete: true),
 CleaningPoint(id: UUID().uuidString, date: .init("2025/06/21 11:43"), minutesSinceMidnight: 703, isComplete: true),
 CleaningPoint(id: UUID().uuidString, date: .init("2025/06/18 18:52"), minutesSinceMidnight: 1132, isComplete: true),
 CleaningPoint(id: UUID().uuidString, date: .init("2025/06/15 12:03"), minutesSinceMidnight: 723, isComplete: true),
 CleaningPoint(id: UUID().uuidString, date: .init("2025/06/12 18:19"), minutesSinceMidnight: 1099, isComplete: true),
 CleaningPoint(id: UUID().uuidString, date: .init("2025/06/09 17:08"), minutesSinceMidnight: 1028, isComplete: true),
 CleaningPoint(id: UUID().uuidString, date: .init("2025/06/06 17:37"), minutesSinceMidnight: 1057, isComplete: true),
 CleaningPoint(id: UUID().uuidString, date: .init("2025/06/03 16:48"), minutesSinceMidnight: 1008, isComplete: true),
 CleaningPoint(id: UUID().uuidString, date: .init("2025/06/01 08:27"), minutesSinceMidnight: 507, isComplete: true),
 CleaningPoint(id: UUID().uuidString, date: .init("2025/05/28 18:33"), minutesSinceMidnight: 1113, isComplete: true),
 CleaningPoint(id: UUID().uuidString, date: .init("2025/05/25 20:29"), minutesSinceMidnight: 1229, isComplete: true),
 CleaningPoint(id: UUID().uuidString, date: .init("2025/05/22 17:10"), minutesSinceMidnight: 1030, isComplete: true),
 CleaningPoint(id: UUID().uuidString, date: .init("2025/05/19 17:08"), minutesSinceMidnight: 1028, isComplete: true),
 */
