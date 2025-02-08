//
//  Statistics.swift
//  SleepyBell
//
//  Created by JoeyHammoth on 2/7/25.
//

import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import Charts

enum SleepEventType: String {
    case gotUp = "Got Up for the Day"
    case wokeButSlept = "Woke but Went Back to Sleep"
}

struct DayHour: Hashable {
    let day: Date
    let hour: Int
}

struct SleepEvent: Identifiable {
    let id = UUID()
    let date: Date         // full date + time of event
    let eventType: SleepEventType
    
    /// Computed property to get the time-of-day (in seconds after midnight)
    var secondsFromMidnight: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: date)
        return (components.hour ?? 0) * 3600 +
               (components.minute ?? 0) * 60 +
               (components.second ?? 0)
    }
}

/// A new model for aggregated (binned) heat map data.
struct SleepHeatMapData: Identifiable {
    let id = UUID()
    let day: Date      // For simplicity, the start of day
    let hour: Int      // The hour of the day (0...23)
    let count: Int     // How many events occurred in that bin
}

struct Statistics: View {
    
    @Binding var showForm: Bool
    @Binding var sleepDateList: [String]
    @Binding var wakeDateList: [String]
    @Binding var sleepList: [String]
    @Binding var wakeList: [String]
    
    @State private var offsetY: CGFloat = 400  // Start hidden below screen
    @State private var lastOffset: CGFloat = 400 // Store last position to prevent jumps
    @State private var dragOffset: CGFloat = 0     // Track user movement
    
    // MARK: - Chart Zoom & Pan State
    @State private var chartScale: CGFloat = 1.0
    @State private var cumulativeChartScale: CGFloat = 1.0
    @State private var chartDragOffset: CGSize = .zero
    @State private var cumulativeChartDragOffset: CGSize = .zero
    
    @State private var yAxisStride: Int = 6000
    
    @State private var enableDummyData: Bool = false
    
    // For testing purposes
    // MARK: - arr1: 100 scattered time strings (mix of AM/PM)
    // This array includes the 10 common time strings (highlighted below)
    // that should also appear in arr2.
    @State private var arr1: [String] = [
      "10:37:29 AM", "03:27:13 AM", "11:42:07 AM", "07:15:32 AM", "01:59:45 AM",
      "12:34:56 AM", "05:22:10 AM", "09:12:45 AM", "02:05:59 AM", "06:33:22 AM",
      "04:18:06 AM", "08:44:55 AM",
      // common: "07:07:07 AM"
      "07:07:07 AM",
      // common: "11:11:11 AM"
      "11:11:11 AM",
      "03:03:21 AM", "10:10:10 AM", "01:01:01 AM", "09:09:09 AM", "06:50:00 AM",
      // common: "09:45:20 AM" (replacing a different value)
      "09:45:20 AM",
      "05:45:30 AM", "12:00:01 AM", "08:20:15 AM", "04:55:05 AM", "03:33:33 AM",
      "11:23:59 AM", "02:46:30 AM", "06:06:06 AM", "09:38:21 AM",
      // common: "10:30:10 PM" (inserted in place of "10:47:58 AM")
      "10:30:10 PM",
      "01:12:34 AM", "12:59:59 AM", "05:10:10 AM", "08:30:45 AM", "07:28:37 AM",
      "04:20:20 AM", "03:40:50 AM", "11:05:15 AM", "06:27:27 AM",
      // common: "12:00:00 PM" (inserted here)
      "12:00:00 PM",
      "09:49:55 AM", "10:03:17 AM", "01:15:15 AM", "12:12:12 AM", "05:55:55 AM",
      "08:08:08 AM", "07:36:36 AM", "04:42:42 AM", "03:21:21 AM",
      // common: "01:23:45 PM" (inserted here)
      "01:23:45 PM",
      "06:18:18 AM", "02:22:22 AM", "09:44:44 AM", "10:27:27 AM", "01:38:38 AM",
      "12:49:49 AM", "05:03:03 AM", "08:16:16 AM", "04:29:29 AM", "07:52:52 AM",
      "03:15:15 AM", "11:23:23 AM", "06:37:37 AM", "02:41:41 AM", "09:56:56 AM",
      "10:08:08 AM", "01:20:20 AM", "12:34:34 AM", "05:47:47 AM", "08:03:03 AM",
      // common: "04:56:34 AM" (inserted in place of "07:30:30 AM")
      "04:56:34 AM",
      "04:17:17 AM", "03:44:44 AM", "11:02:02 AM", "06:16:16 AM", "02:30:30 AM",
      "09:55:55 AM", "10:14:14 AM", "01:28:28 AM", "12:42:42 AM", "05:56:56 AM",
      "08:10:10 AM", "04:24:24 AM", "07:38:38 AM", "03:52:52 AM", "11:06:06 AM",
      "06:20:20 AM",
      // common: "02:34:56 AM" (ensured here)
      "02:34:56 AM",
      "09:48:48 AM",
      // common: "07:07:07 PM" (inserted in place of "10:02:02 AM")
      "07:07:07 PM",
      "01:16:16 AM", "12:30:30 AM", "05:44:44 AM", "08:58:58 AM", "04:12:12 AM",
      "07:26:26 AM", "03:40:40 AM", "11:54:54 AM", "06:08:08 AM",
      // common: "03:21:09 PM" (inserted at the end)
      "03:21:09 PM"
    ]

    // MARK: - arr2: 100 scattered time strings (mix of AM/PM)
    // This array also contains the same 10 common time strings (in exactly the same form)
    // so that arr1 and arr2 overlap.
    @State private var arr2: [String] = [
      "03:11:22 PM", "08:55:44 AM", "12:22:33 PM", "05:44:55 PM", "09:33:21 AM",
      "11:17:29 PM", "04:07:08 AM",
      // common: "07:07:07 AM"
      "07:07:07 AM",
      "10:10:10 PM", "01:05:05 PM", "02:02:02 AM", "06:06:06 PM",
      // common: "11:11:11 AM"
      "11:11:11 AM",
      "03:45:00 AM",
      "08:08:08 PM",
      // common: "09:45:20 AM"
      "09:45:20 AM",
      "10:50:50 AM",
      // common: "12:00:00 PM"
      "12:00:00 PM",
      "01:30:30 PM", "02:20:20 PM", "04:40:40 AM", "05:55:55 PM", "07:15:15 PM",
      "08:25:25 AM", "09:35:35 AM",
      // common: "10:30:10 PM"
      "10:30:10 PM",
      "11:40:40 AM", "12:50:50 PM",
      // common: "01:23:45 PM"
      "01:23:45 PM",
      "02:33:33 PM", "03:43:43 AM", "04:53:53 PM", "05:03:03 AM", "06:13:13 PM",
      "07:23:23 AM", "08:33:33 PM", "09:43:43 AM", "10:53:53 PM", "11:07:07 PM",
      "12:17:17 AM", "01:27:27 PM",
      // common: "02:34:56 AM" (replacing a nearby value)
      "02:34:56 AM",
      "03:47:47 PM", "04:57:57 AM", "05:07:07 PM", "06:17:17 AM", "07:27:27 PM",
      "08:37:37 AM", "09:47:47 PM", "10:57:57 AM",
      // common: "07:07:07 PM"
      "07:07:07 PM",
      "08:27:27 AM", "09:37:37 PM", "10:47:47 AM", "11:57:57 PM", "12:07:07 AM",
      "01:17:17 PM", "02:27:27 AM", "03:37:37 PM", "04:47:47 AM", "05:57:57 PM",
      "06:07:07 AM", "07:17:17 PM", "08:27:27 PM", "09:37:37 AM", "10:47:47 PM",
      "11:11:11 PM", "12:21:21 AM", "01:31:31 PM", "02:41:41 PM", "03:51:51 AM",
      "04:01:01 PM", "05:11:11 AM", "06:21:21 PM", "07:31:31 AM", "08:41:41 PM",
      "09:51:51 AM", "10:01:01 PM",
      // common: "11:11:11 AM" (again, as duplicate is allowed)
      "11:11:11 AM",
      "12:01:01 PM", "01:11:11 AM", "02:21:21 PM", "03:31:31 AM", "04:41:41 PM",
      "05:51:51 AM", "06:01:01 PM", "07:21:21 AM", "08:31:31 PM", "09:41:41 AM",
      "10:51:51 PM",
      // common: "03:21:09 PM"
      "03:21:09 PM",
      // common: "04:56:34 AM"
      "04:56:34 AM"
    ]

    // MARK: - arr3: 100 scattered date strings ("yyyy-mm-dd")
    // This array includes the 10 common date strings (below) that will also appear in arr4.
    @State private var arr3: [String] = [
      "2025-03-15", "2021-11-04", "2023-06-29", "2022-01-12", "2020-07-23",
      "2024-12-31", "2021-04-05", "2023-09-17",
      // common: "2022-08-08"
      "2022-08-08",
      "2025-02-28", "2020-05-19", "2024-03-11", "2021-10-10", "2023-01-01",
      "2022-11-11", "2025-07-07", "2020-12-25", "2024-06-30", "2021-02-14",
      "2023-04-04", "2022-09-09", "2025-01-20", "2020-08-08", "2024-02-29",
      // common: "2021-03-03"
      "2021-03-03",
      "2023-11-23", "2022-05-05",
      // common: "2025-06-06"
      "2025-06-06",
      // common: "2020-10-10"
      "2020-10-10",
      // common: "2024-01-01"
      "2024-01-01",
      // common: "2021-07-07"
      "2021-07-07",
      "2023-08-08", "2022-04-04", "2025-05-15", "2020-11-11", "2024-07-04",
      "2021-09-09", "2023-12-12", "2022-02-02", "2025-03-03", "2020-06-06",
      "2024-09-09", "2021-12-31",
      // common: "2023-05-05"
      "2023-05-05",
      "2022-03-03", "2025-08-08", "2020-04-04", "2024-11-11", "2021-01-01",
      "2023-07-07", "2022-10-10", "2025-09-09", "2020-03-03", "2024-08-08",
      "2021-06-06", "2023-10-10", "2022-07-07", "2025-10-10", "2020-02-02",
      "2024-10-10", "2021-08-08", "2023-03-03", "2022-06-06", "2025-04-04",
      "2020-09-09", "2024-05-05",
      // common: "2023-11-11"
      "2023-11-11",
      "2023-02-02", "2022-12-12", "2025-11-11", "2020-01-01", "2024-04-04",
      "2021-05-05", "2023-06-06", "2022-08-08", "2025-12-12", "2020-07-07",
      "2024-12-12", "2021-04-04", "2023-09-09", "2022-11-11",
      // common: "2025-01-01"
      "2025-01-01",
      "2020-08-08", "2024-02-02", "2021-03-03", "2023-11-11", "2022-05-05",
      "2025-06-06", "2020-10-10", "2024-01-01", "2021-07-07", "2023-08-08",
      "2022-04-04", "2025-05-15", "2020-11-11"
    ]

    // MARK: - arr4: 100 scattered date strings ("yyyy-mm-dd")
    // We now force overlap with arr3 by ensuring the same 10 common date strings appear here too.
    // (In this arr4 the values are arbitrarily chosen from various years.)
    @State private var arr4: [String] = [
      // Replace some entries with the common dates:
      // common: "2022-08-08"
      "2022-08-08",
      "2020-12-11", "2019-07-04", "2021-03-19", "2018-11-30",
      // common: "2025-06-06"
      "2025-06-06",
      "2019-04-22", "2021-09-08", "2018-08-16", "2020-06-06", "2019-12-25",
      "2021-11-11", "2018-02-14", "2020-03-03", "2019-10-10",
      // common: "2021-07-07"
      "2021-07-07",
      "2018-09-09", "2020-04-04", "2019-05-05",
      // common: "2021-01-01" is already common in arr3; here we replace an element:
      "2021-01-01",
      "2018-06-15", "2020-08-08", "2019-11-11", "2021-02-02", "2018-10-10",
      "2020-11-11", "2019-03-03", "2021-05-05", "2018-12-31",
      // common: "2020-07-07"
      "2020-07-07",
      "2019-01-01", "2021-04-04", "2024-09-09", "2020-09-09", "2019-06-06",
      "2021-10-10", "2018-03-03",
      // common: "2023-11-11" (inserted here)
      "2023-11-11",
      "2019-08-08", "2021-12-12", "2018-07-07", "2020-05-05", "2019-09-09",
      "2021-06-06", "2018-01-01", "2020-02-02", "2019-02-02", "2021-08-08",
      "2018-11-11",
      // common: "2024-01-01" (inserted here)
      "2024-01-01",
      "2019-04-04", "2021-03-03", "2018-08-08", "2020-01-01", "2019-07-07",
      "2021-05-05", "2018-09-09", "2020-03-03",
      // common: "2023-05-05" (inserted here)
      "2023-05-05",
      "2021-07-07", "2018-06-06", "2020-08-08", "2019-12-12",
      // common: "2025-01-01" (inserted here)
      "2025-01-01",
      "2018-05-05", "2020-11-11", "2019-03-03", "2021-04-04", "2018-10-10",
      "2020-07-07", "2019-01-01", "2021-09-09", "2018-04-14", "2020-09-19",
      "2019-06-16", "2021-10-20", "2018-03-12", "2020-10-22", "2019-08-29",
      "2021-12-31", "2018-07-23", "2020-05-17", "2019-09-07", "2021-06-27",
      "2018-01-21", "2020-02-28", "2019-02-18", "2021-08-30", "2018-11-05",
      "2020-12-03", "2019-04-17", "2021-03-29", "2018-08-11", "2020-01-09",
      "2019-07-29", "2021-05-19", "2018-09-15", "2020-03-27", "2019-10-23",
      "2021-07-31"
    ]


    
    let maxYValue = 86400
    
    var computedYAxisValues: [Int] {
        Array(stride(from: 0, to: maxYValue, by: yAxisStride))
    }
    
    var sleepEvents: [SleepEvent] {
        var events: [SleepEvent] = []
        var wakeTemp: [String]
        var sleepTemp: [String]
        var wakeDateTemp: [String]
        var sleepDateTemp: [String]
        
        if !enableDummyData {
            wakeTemp = wakeList
            sleepTemp = sleepList
            wakeDateTemp = wakeDateList
            sleepDateTemp = sleepDateList
        } else {
            wakeTemp = arr1
            sleepTemp = arr2
            wakeDateTemp = arr3
            sleepDateTemp = arr4
        }
        
        // Process "got up" events (will be shown in blue)
        for (dateStr, timeStr) in zip(wakeDateTemp, wakeTemp) {
            if let date = makeDate(date: dateStr, time: timeStr) {
                events.append(SleepEvent(date: date, eventType: .gotUp))
            }
        }
        
        // Process "woke but went back to sleep" events (will be shown in red)
        for (dateStr, timeStr) in zip(sleepDateTemp, sleepTemp) {
            if let date = makeDate(date: dateStr, time: timeStr) {
                events.append(SleepEvent(date: date, eventType: .wokeButSlept))
            }
        }
        return events
    }
    
    /// Combines a date string (e.g., "2025-01-01") and a time string (e.g., "07:00:00 AM")
    /// into a Date object.
    func makeDate(date: String, time: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX") // Ensure consistent parsing
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss a" // 12‑hour format with AM/PM
        return formatter.date(from: "\(date) \(time)")
    }
    
    /// A helper to aggregate your SleepEvent data into hourly bins.
    func aggregateSleepEventsToHeatMapData(_ events: [SleepEvent]) -> [SleepHeatMapData] {
        let calendar = Calendar.current
        // Group events by day (startOfDay) and hour.
        let grouped = Dictionary(grouping: events) { event -> DayHour in
            let day = calendar.startOfDay(for: event.date)
            let hour = calendar.component(.hour, from: event.date)
            return DayHour(day: day, hour: hour)
        }
        // Convert each group into a SleepHeatMapData instance.
        return grouped.map { (key, events) in
            return SleepHeatMapData(day: key.day, hour: key.hour, count: events.count)
        }
    }
    
    var heatData: [SleepHeatMapData] {
        aggregateSleepEventsToHeatMapData(sleepEvents)
    }
    
    /// Generates a random time string in the "hh:mm:ss AM/PM" format.
    func randomTimeString() -> String {
        // Hours in 12-hour format: 1 to 12.
        let hour = Int.random(in: 1...12)
        // Minutes and seconds: 0 to 59.
        let minute = Int.random(in: 0...59)
        let second = Int.random(in: 0...59)
        // Randomly choose between AM and PM.
        let period = Bool.random() ? "AM" : "PM"
        return String(format: "%02d:%02d:%02d %@", hour, minute, second, period)
    }

    /// Generates a random date string in the "yyyy-MM-dd" format.
    /// To keep it simple, the day is chosen from 1 to 28 to avoid invalid dates.
    func randomDateString() -> String {
        let year = Int.random(in: 2000...2030)
        let month = Int.random(in: 1...12)
        let day = Int.random(in: 1...28)
        return String(format: "%04d-%02d-%02d", year, month, day)
    }

    // MARK: - Main Function to Generate Arrays

    /// Generates 4 arrays with random, scattered data.
    /// - Returns: A tuple containing:
    ///   - arr1: 100 random time strings (scattered), including 10 common ones.
    ///   - arr2: 100 random time strings (scattered), including the same 10 common ones as arr1.
    ///   - arr3: 100 random date strings (scattered), including 10 common ones.
    ///   - arr4: 100 random date strings (scattered), including the same 10 common ones as arr3.
    func generateScatteredData() -> (arr1: [String], arr2: [String], arr3: [String], arr4: [String]) {
        
        // Generate 10 common time strings
        var commonTimes = [String]()
        for _ in 0..<10 {
            commonTimes.append(randomTimeString())
        }
        
        // Create arr1: 90 random time strings + 10 common times, then shuffle.
        var arr1 = [String]()
        for _ in 0..<90 {
            arr1.append(randomTimeString())
        }
        arr1.append(contentsOf: commonTimes)
        arr1.shuffle()
        
        // Create arr2: 90 random time strings + same 10 common times, then shuffle.
        var arr2 = [String]()
        for _ in 0..<90 {
            arr2.append(randomTimeString())
        }
        arr2.append(contentsOf: commonTimes)
        arr2.shuffle()
        
        // Generate 10 common date strings
        var commonDates = [String]()
        for _ in 0..<10 {
            commonDates.append(randomDateString())
        }
        
        // Create arr3: 90 random date strings + 10 common dates, then shuffle.
        var arr3 = [String]()
        for _ in 0..<90 {
            arr3.append(randomDateString())
        }
        arr3.append(contentsOf: commonDates)
        arr3.shuffle()
        
        // Create arr4: 90 random date strings + same 10 common dates, then shuffle.
        var arr4 = [String]()
        for _ in 0..<90 {
            arr4.append(randomDateString())
        }
        arr4.append(contentsOf: commonDates)
        arr4.shuffle()
        
        return (arr1, arr2, arr3, arr4)
    }

    var body: some View {
        VStack {
            Capsule()
                .frame(width: 50, height: 5)
                .foregroundColor(.gray.opacity(0.8))
                .padding(5)
            
            NavigationStack {
                Form {
                    
                    Section {
                        ForEach(Array(zip(sleepList, sleepDateList).enumerated()), id: \.offset) { index, pair in
                            HStack {
                                VStack {
                                    Text("\(pair.0)")
                                        .font(.system(size: 30, weight: .bold))
                                    Text("\(pair.1)")
                                        .font(.system(size: 20, weight: .light))
                                }
                                Spacer()
                                Text("\(index)")
                                    .font(.system(size: 50, weight: .black))
                            }
                        }
                    } header: {
                        Text("Times when you went back to sleep")
                            .foregroundStyle(Color.white)
                            .fontWeight(.bold)
                    }
                    
                    Section {
                        ForEach(Array(zip(wakeList, wakeDateList).enumerated()), id: \.offset) { index, pair in
                            HStack {
                                VStack {
                                    Text("\(pair.0)")
                                        .font(.system(size: 30, weight: .bold))
                                    Text("\(pair.1)")
                                        .font(.system(size: 20, weight: .light))
                                }
                                Spacer()
                                Text("\(index)")
                                    .font(.system(size: 50, weight: .black))
                            }
                        }
                    } header: {
                        Text("Times when you woke up")
                            .foregroundStyle(Color.white)
                            .fontWeight(.bold)
                    }
                    
                    Section {
                        // Wrap the Chart with zoom and pan modifiers.
                        Chart {
                            ForEach(sleepEvents) { event in
                                PointMark(
                                    x: .value("Date", event.date, unit: .day),
                                    y: .value("Time (seconds)", event.secondsFromMidnight)
                                )
                                // Differentiate the events by color and symbol.
                                .foregroundStyle(event.eventType == .gotUp ? .blue : .red)
                                .symbol(event.eventType == .gotUp ? .circle : .square)
                            }
                        }
                        .chartYAxis {
                            AxisMarks(values: computedYAxisValues) { value in
                                if let seconds = value.as(Int.self) {
                                    let hour24 = seconds / 3600
                                    let minute = (seconds % 3600) / 60
                                    let hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12
                                    let period = hour24 >= 12 ? "PM" : "AM"
                                    let labelText = String(format: "%02d:%02d %@", hour12, minute, period)
                                    AxisGridLine()
                                    AxisValueLabel(labelText)
                                }
                            }
                        }
                        .chartYScale(domain: 0...maxYValue)
                        .chartXAxis {
                            AxisMarks(values: .automatic) { value in
                                let labelText: String = {
                                    if let date = value.as(Date.self) {
                                        let formatter = DateFormatter()
                                        formatter.dateStyle = .short
                                        return formatter.string(from: date)
                                    } else {
                                        return ""
                                    }
                                }()
                                AxisGridLine()
                                AxisValueLabel(labelText)
                            }
                        }
                        .frame(height: 300)
                        // Apply zoom (scale) and pan (offset) effects.
                        .scaleEffect(cumulativeChartScale * chartScale)
                        .offset(x: cumulativeChartDragOffset.width + chartDragOffset.width,
                                y: cumulativeChartDragOffset.height + chartDragOffset.height)
                        // Attach the magnification (pinch) gesture.
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    chartScale = value
                                }
                                .onEnded { value in
                                    cumulativeChartScale *= value
                                    chartScale = 1.0
                                }
                        )
                        // Attach the drag (pan) gesture simultaneously.
                        .simultaneousGesture(
                            DragGesture()
                                .onChanged { value in
                                    chartDragOffset = value.translation
                                }
                                .onEnded { value in
                                    cumulativeChartDragOffset.width += value.translation.width
                                    cumulativeChartDragOffset.height += value.translation.height
                                    chartDragOffset = .zero
                                }
                        )
                        Button("Reset Chart") {
                            chartScale = 1.0
                            cumulativeChartScale = 1.0
                            chartDragOffset = .zero
                            cumulativeChartDragOffset = .zero
                        }
                        VStack {
                            Text("Y-Axis Stride: \(yAxisStride)")
                            Slider(value: Binding(
                                get: {
                                    Double(yAxisStride)
                                },
                                set: { newValue in
                                    yAxisStride = Int(newValue)
                                }),
                                   in: 300...20000, step: 300
                            )
                        }
                    } header: {
                        Text("Scatter Plot")
                            .foregroundStyle(Color.white)
                            .fontWeight(.bold)
                    }
                    
                    Section {
                        Chart(heatData) { cell in
                            BarMark(
                                       x: .value("Day", cell.day),
                                       y: .value("Hour", cell.hour)
                                   )
                            // Map the cell's count to a color.
                            .foregroundStyle(by: .value("Count", cell.count))
                        }
                        // Define a continuous color scale (adjust the colors as desired).
                        .chartForegroundStyleScale(
                            range: Gradient(colors: [.blue, .red])
                        )
                        .frame(height: 300)
                    } header: {
                        Text("HeatMap")
                            .foregroundStyle(Color.white)
                            .fontWeight(.bold)
                    }
                    
                    Section {
                        Toggle(isOn: $enableDummyData) {
                            Text("Enable Dummy Data")
                        }
                        Button("Generate Random Dummy Data") {
                            (arr1, arr2, arr3, arr4) = generateScatteredData()
                        }
                    } header: {
                        Text("Dummy Data")
                            .foregroundStyle(Color.white)
                            .fontWeight(.bold)
                    }
                    
                }
                .navigationTitle("Statistics")
                .scrollContentBackground(.hidden) // Hide form background
            }
            .introspect(.navigationStack, on: .iOS(.v16...)) { navigationStack in
                navigationStack.viewControllers.forEach { controller in
                    controller.view.backgroundColor = .clear
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial) // Transparent blur effect
        .ignoresSafeArea()
        .offset(y: offsetY + dragOffset)  // Combine base offset with drag movement for the overall view.
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    dragOffset = gesture.translation.height // Move dynamically.
                }
                .onEnded { _ in
                    let newOffset = offsetY + dragOffset
                    
                    if newOffset > 250 {  // Close form if dragged down far.
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            offsetY = UIScreen.main.bounds.height
                            showForm = false
                        }
                    } else {  // Snap back up if not dragged far enough.
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            offsetY = 0
                        }
                    }
                    
                    dragOffset = 0  // Reset the drag movement.
                }
        )
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                offsetY = 0
                lastOffset = 0
            }
        }
        .onChange(of: showForm) {
            if showForm {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    offsetY = 0
                    lastOffset = 0
                }
            } else {
                offsetY = UIScreen.main.bounds.height
            }
        }
    }
}
