//
//  Form.swift
//  SleepyBell
//
//  Created by James Nikolas on 1/31/25.
//

import SwiftUI

struct AlarmList {
    var idList: [Int] = []
    var primaryList: [String] = []
    var secList: [Int] = []
    var minList: [Int] = []
    var hourList: [Int] = []
    var dayList: [String] = []
    
    var layout: [String] {
        var arr: [String] = []
        for i in 0..<idList.count {
            if (hourList[i] < 10 && minList[i] < 10 && secList[i] < 10) {
                arr.append("0\(hourList[i]):0\(minList[i]):0\(secList[i]) \(dayList[i])")
            } else if (hourList[i]  >= 10 && minList[i] < 10 && secList[i] < 10) {
                arr.append("\(hourList[i]):0\(minList[i]):0\(secList[i]) \(dayList[i])")
            } else if (hourList[i]  >= 10 && minList[i] >= 10 && secList[i] < 10) {
                arr.append("\(hourList[i]):\(minList[i]):0\(secList[i]) \(dayList[i])")
            } else if (hourList[i]  >= 10 && minList[i] < 10 && secList[i] >= 10) {
                arr.append("\(hourList[i]):0\(minList[i]):\(secList[i]) \(dayList[i])")
            } else if (hourList[i]  < 10 && minList[i] < 10 && secList[i] >= 10) {
                arr.append("0\(hourList[i]):0\(minList[i]):\(secList[i]) \(dayList[i])")
            } else if (hourList[i]  < 10 && minList[i] >= 10 && secList[i] < 10) {
                arr.append("0\(hourList[i]):\(minList[i]):0\(secList[i]) \(dayList[i])")
            } else {
                arr.append("\(hourList[i]):\(minList[i]):\(secList[i]) \(dayList[i])")
            }
        }
        return arr
    }
}


struct DraggableTransparentForm: View {
    let dayNightList = ["Light", "Dark"]
    let primList = ["Primary", "Secondary"]
    
    // @Binding var dayNight: String
    @Binding var mode: String
    @Binding var showForm: Bool
    
    
    @State private var offsetY: CGFloat = 400  // Start hidden below screen
    @State private var lastOffset: CGFloat = 400 // Store last position to prevent jumps
    @State private var dragOffset: CGFloat = 0 // Track user movement
    @State private var alarms: AlarmList = AlarmList()
    
    // Temp vars for each alarm
    @State private var sec: Int = 0
    @State private var min: Int = 0
    @State private var hour: Int = 1
    @State private var day: String = "AM"
    @State private var primary: String = "Primary"
    

    var body: some View {
        VStack {
            Capsule()
                .frame(width: 50, height: 5)
                .foregroundColor(.gray.opacity(0.8))
                .padding(5)
            Form {
                Section("About") {
                    Text("This is your list of alarms. Start setting up your main alarm which is set to the time that you ideally want to wake up. Afterwards, create a number of several alarms in whatever increments you want. These secondary alarms will set off and will prompt you as to whether you have woken up or not. They cannot be deactivated after creation.")
                }
                
                ForEach(0..<alarms.idList.count, id: \.self) { index in // Must use explicit closure parameter index instead of $0
                    Section {
                        Text(alarms.layout[index])
                    } header: {
                        Text("Alarm \(alarms.idList[index]) (\(alarms.primaryList[index]))")
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                Section("Add new alarm") {
                    Picker("Second", selection: $sec) {
                        ForEach(0..<60, id: \.self) {
                            Text("\($0)")
                        }
                    }
                    Picker("Minute", selection: $min) {
                        ForEach(0..<60, id: \.self) {
                            Text("\($0)")
                        }
                    }
                    Picker("Hour", selection: $hour) {
                        ForEach(1...12, id: \.self) {
                            Text("\($0)")
                        }
                    }
                    Picker("Day/Night", selection: $day) {
                        ForEach(dayNightList, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.segmented)
                    Picker("Primary Alarm", selection: $primary) {
                        ForEach(primList, id: \.self) {
                            Text(String($0))
                        }
                    }
                    .pickerStyle(.segmented)
                    Button("Add Alarm") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            alarms.idList.append(alarms.idList.count + 1)
                            alarms.secList.append(sec)
                            alarms.minList.append(min)
                            alarms.hourList.append(hour)
                            alarms.dayList.append(day)
                            alarms.primaryList.append(primary)
                        }
                    }
                }
                
                Section("Set background") {
                    Picker("Day/Night", selection: $mode) {
                        ForEach(dayNightList, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                
            }
            .scrollContentBackground(.hidden) // Hide form background
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial) // Transparent blur effect
        .ignoresSafeArea()
        .offset(y: offsetY + dragOffset)  // Combine base offset with drag movement
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    dragOffset = gesture.translation.height // Move dynamically
                }
                .onEnded { _ in
                    let newOffset = offsetY + dragOffset
                    
                    if newOffset > 250 {  // Close form if dragged down far
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            offsetY = UIScreen.main.bounds.height
                            showForm = false
                        }
                    } else {  // Snap back up if not dragged far enough
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            offsetY = 0
                        }
                    }
                    
                    dragOffset = 0  // Reset the drag movement
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
