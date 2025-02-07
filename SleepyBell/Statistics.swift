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

struct Statistics: View {
    
    @Binding var showForm: Bool
    @Binding var sleepDateList: [String]
    @Binding var wakeDataList: [String]
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
    
    var sleepEvents: [SleepEvent] {
        var events: [SleepEvent] = []
        // Process "got up" events (will be shown in blue)
        for (dateStr, timeStr) in zip(wakeDataList, wakeList) {
            if let date = makeDate(date: dateStr, time: timeStr) {
                events.append(SleepEvent(date: date, eventType: .gotUp))
            }
        }
        
        // Process "woke but went back to sleep" events (will be shown in red)
        for (dateStr, timeStr) in zip(sleepDateList, sleepList) {
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

    var body: some View {
        VStack {
            Capsule()
                .frame(width: 50, height: 5)
                .foregroundColor(.gray.opacity(0.8))
                .padding(5)
            
            NavigationStack {
                Form {
                    ForEach(Array(zip(sleepList, sleepDateList).enumerated()), id: \.offset) { index, pair in
                        Section() {
                            Text("\(pair.0)")
                                .font(.system(size: 30, weight: .bold))
                            Text("\(pair.1)")
                                .font(.system(size: 20, weight: .light))
                        } header: {
                            Text("Back to Sleep Schedule \(index)")
                        }
                    }
                
                    
                    ForEach(Array(zip(wakeList, wakeDataList).enumerated()), id: \.offset) { index, pair in
                        Section {
                            Text("\(pair.0)")
                                .font(.system(size: 30, weight: .bold))
                            Text("\(pair.1)")
                                .font(.system(size: 20, weight: .light))
                        } header: {
                            Text("Woke Up Schedule \(index)")
                        }
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
                            AxisMarks(values: .stride(by: 7200)) { value in
                                let labelText: String = {
                                    if let seconds = value.as(Int.self) {
                                        // Convert seconds to 12‑hour time components.
                                        let hour24 = seconds / 3600
                                        let minute = (seconds % 3600) / 60
                                        let hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12
                                        let period = hour24 >= 12 ? "PM" : "AM"
                                        return String(format: "%02d:%02d %@", hour12, minute, period)
                                    } else {
                                        return ""
                                    }
                                }()
                                AxisGridLine()
                                AxisValueLabel(labelText)
                            }
                        }
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
                    } header: {
                        Text("Graph")
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



