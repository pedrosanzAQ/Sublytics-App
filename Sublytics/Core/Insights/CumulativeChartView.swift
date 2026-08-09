//
//  Untitled.swift
//  Sublytics
//
//  Created by pedrosanz on 23/03/26.
//
import SwiftUI
import Charts

struct ExpensePoint: Identifiable {
    let id = UUID()
    let offset: Int
    let total: Double
    let calendarDay: Int
}

struct CumulativeChartView: View {
    let subscriptions: [SubscriptionModel]
    
    var daysInCurrentMonth: Int {
        let range = Calendar.current.range(of: .day, in: .month, for: Date())
        return range?.count ?? 30
    }
    
    var activeData: [ExpensePoint] {
        let activeSubs = subscriptions.filter { $0.status == .active }
        let maxDays = daysInCurrentMonth
        let calendar = Calendar.current
        let hoyDia = calendar.component(.day, from: Date())
        
        let chargesWithOffsets = activeSubs.map { sub -> (offset: Int, price: Double) in
            let offset = min(max(sub.remainingDays, 0), maxDays)
            return (offset: offset, price: sub.monthlyPrice)
        }
        
        var dailyTotals: [Int: Double] = [:]
        for charge in chargesWithOffsets {
            dailyTotals[charge.offset, default: 0.0] += charge.price
        }
    
        let sortedOffsets = dailyTotals.keys.sorted()
        
        var points: [ExpensePoint] = []
        var currentTotal: Double = 0
        
        points.append(ExpensePoint(offset: 0, total: 0, calendarDay: hoyDia))
        
        for offset in sortedOffsets where offset > 0 {
            currentTotal += dailyTotals[offset] ?? 0
            let calDay = ((hoyDia - 1 + offset) % maxDays) + 1
            points.append(ExpensePoint(offset: offset, total: currentTotal, calendarDay: calDay))
        }
        
        if let todayCharge = dailyTotals[0] {
            currentTotal += todayCharge
            points[0] = ExpensePoint(offset: 0, total: 0, calendarDay: hoyDia)
            points.append(ExpensePoint(offset: 0, total: todayCharge, calendarDay: hoyDia))
        }
        
        if let last = points.last, last.offset < maxDays {
            points.append(ExpensePoint(offset: maxDays, total: currentTotal, calendarDay: ((hoyDia - 1 + maxDays) % maxDays) + 1))
        }
        
        return points.sorted(by: { $0.offset < $1.offset })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            headerView
            
            Chart {
                ForEach(activeData) { point in
                    LineMark(
                        x: .value("Day", point.offset),
                        y: .value("Total", point.total)
                    )
                    .foregroundStyle(Color.green)
                    .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                    
                    AreaMark(
                        x: .value("Day", point.offset),
                        y: .value("Total", point.total)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.green.opacity(0.3), Color.green.opacity(0.0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    if point.offset > 0 && point.offset < daysInCurrentMonth {
                        PointMark(
                            x: .value("Day", point.offset),
                            y: .value("Total", point.total)
                        )
                        .foregroundStyle(Color.green)
                        .symbolSize(80)
                        .annotation(position: .top, alignment: .center, spacing: 5) {
                            labelView(for: point.calendarDay)
                        }
                    }
                }
            }
            .chartXScale(domain: 0...daysInCurrentMonth)
            .chartXAxis { xAxisMarks }
            .chartYAxis { yAxisMarks }
            .frame(height: 190)
        }
        .padding(20)
        .background(Color(white: 0.1))
        .cornerRadius(24)
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("MENSUAL PROYECTION").font(.caption).bold().foregroundColor(.gray)
            Text(activeData.last?.total ?? 0, format: .currency(code: "MXN"))
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
    }
    
    private func labelView(for calendarDay: Int) -> some View {
        VStack(spacing: 0) {
            Text("Day \(calendarDay)")
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.black.opacity(0.6))
        .cornerRadius(6)
    }
    
    private var xAxisMarks: some AxisContent {
        AxisMarks(values: .stride(by: 7)) { value in
            AxisGridLine().foregroundStyle(.white.opacity(0.05))
            AxisValueLabel {
                if let offset = value.as(Int.self) {
                    Text("\(offset)").font(.caption2).foregroundColor(.gray)
                }
            }
        }
    }
    
    private var yAxisMarks: some AxisContent {
        AxisMarks(position: .leading) { value in
            AxisGridLine().foregroundStyle(.white.opacity(0.05))
            AxisValueLabel {
                if let amount = value.as(Double.self) {
                    Text(amount, format: .currency(code: "MXN").precision(.fractionLength(0)))
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.gray)
                }
            }
        }
    }
}
