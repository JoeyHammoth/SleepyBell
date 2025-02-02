//
//  Form.swift
//  SleepyBell
//
//  Created by James Nikolas on 1/31/25.
//

import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect

struct HandView: View {
    
    /// The length of the hand (the vertical size of the rectangle).
    let length: CGFloat
    
    /// The thickness of the hand (the horizontal size of the rectangle).
    let thickness: CGFloat
    
    /// The color of the hand. Default is white.
    let color: Color
    
    /// Creates a new `HandView` instance with the specified length, thickness, and optional color.
    ///
    /// - Parameters:
    ///   - length: The vertical length of the hand (in points).
    ///   - thickness: The horizontal thickness of the hand (in points).
    ///   - color: The color of the hand. Defaults to `.white` if not specified.
    init(length: CGFloat, thickness: CGFloat, color: Color = .white) {
        self.length = length
        self.thickness = thickness
        self.color = color
    }
    
    /// The view's content and layout.
    ///
    /// The body of the view creates a rectangle with the specified color and frame size. The rectangle is then offset vertically to align the bottom edge to the center.
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: thickness, height: length)
            .offset(y: -length / 2)  // Align bottom at center
    }
}

struct AlarmList {
    var idList: [Int] = []
    
    var primaryList: [String] {
        var primArr: [String] = []
        for i in 0..<idList.count {
            if i == 0 {
                primArr.append("Primary")
            } else {
                primArr.append("Secondary")
            }
        }
        return primArr
    }
    
    var secList: [Int] = []
    var minList: [Int] = []
    var hourList: [Int] = []
    var dayList: [String] = []
    
    var realHourList: [Int] {
        var realHourArr: [Int] = []
        for i in 0..<idList.count {
            if dayList[i] == "AM" {
                if hourList[i] == 12 {
                    realHourArr.append(24)
                } else {
                    realHourArr.append(hourList[i])
                }
            } else {
                if hourList[i] == 12 {
                    realHourArr.append(12)
                } else {
                    realHourArr.append(hourList[i] + 12)
                }
            }
        }
        return realHourArr
    }
    
    var mornList: [String] {
        var mornArr: [String] = []
        for i in 0..<idList.count {
            if realHourList[i] >= 6 && realHourList[i] < 18 {
                mornArr.append("Morning")
            } else {
                mornArr.append("Night")
            }
        }
        return mornArr
    }
    
    var diffList: [Int] {
        var diffArr: [Int] = []
        var hourDiff: Int = 0
        var minDiff: Int = 0
        var secDiff: Int = 0
        
        for i in 0..<idList.count {
            if i == 0 {
                diffArr.append(0)
            } else {
                hourDiff = (realHourList[i] - realHourList[i-1]) * 3600
                minDiff = (minList[i] - minList[i-1]) * 60
                secDiff = secList[i] - secList[i-1]
                diffArr.append(hourDiff + minDiff + secDiff)
            }
        }
        return diffArr
    }
    
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
    
    mutating func removeLastAll() {
        idList.removeLast()
        secList.removeLast()
        minList.removeLast()
        hourList.removeLast()
        dayList.removeLast()
    }
}


struct DraggableTransparentForm: View {
    
    let dayNightList = ["AM", "PM"]
    let primList = ["Primary", "Secondary"]
    
    // @Binding var dayNight: String
    @Binding var mode: String
    @Binding var showForm: Bool
    @Binding var alertBool: Bool
    
    @Binding var alarms: AlarmList
    
    
    @State private var offsetY: CGFloat = 400  // Start hidden below screen
    @State private var lastOffset: CGFloat = 400 // Store last position to prevent jumps
    @State private var dragOffset: CGFloat = 0 // Track user movement
    //@State private var alarms: AlarmList = AlarmList()
    
    // Temp vars for each alarm
    @State private var sec: Int = 0
    @State private var min: Int = 0
    @State private var hour: Int = 1
    @State private var day: String = "AM"
    
    @State private var mornGradColors: [Color] = [Color.cyan, Color.white]
    @State private var nightGradColors: [Color] = [Color.black.opacity(0.5), Color.blue.opacity(0.5)]
    
    func animateGradientMorn() {
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 3)) {
                if mornGradColors == [Color.cyan, Color.white] {
                    mornGradColors = [Color.yellow, Color.cyan, Color.white] // Simulating noon
                } else {
                    mornGradColors = [Color.cyan, Color.white] // Reset to morning
                }
            }
        }
    }
    
    func animateGradientNight() {
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 3)) {
                if nightGradColors == [Color.black.opacity(0.5), Color.blue.opacity(0.5)] {
                    nightGradColors = [Color.black.opacity(0.8), Color.blue.opacity(0.2)] // Simulating night
                } else {
                    nightGradColors = [Color.black.opacity(0.5), Color.blue.opacity(0.5)] // Reset to evening
                }
            }
        }
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
                        Text("""
                        This is your list of alarms. Start setting up your main alarm which is set to the time that you ideally want to wake up.
                        
                        Afterwards, create a number of several alarms in whatever increments you want.
                        
                        These secondary alarms will set off and will prompt you as to whether you have woken up or not.
                        
                        
                        """) +
                        Text("""
                        They cannot be deactivated until all alarms have ringed.
                        """)
                        .foregroundColor(Color.red)
                    } header: {
                        Text("About")
                            .foregroundStyle(mode == "Dark" ? Color.gray : Color.white)
                    }
                    
                    ForEach(0..<alarms.idList.count, id: \.self) { index in // Must use explicit closure parameter index instead of $0
                        Section {
                            HStack {
                                Text(alarms.layout[index])
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundStyle(Color.white)
                                Spacer()
                                ZStack {
                                    Circle()
                                        .stroke(lineWidth:5)
                                        .padding(8)
                                        .foregroundColor(Color.white)
                                    
                                    HandView(length: 60, thickness: 3, color: .white)
                                        .rotationEffect(.degrees(Double(alarms.secList[index]) * 6), anchor: .center)
                                    
                                    HandView(length: 50, thickness: 6, color: .white)
                                        .rotationEffect(.degrees(Double(alarms.minList[index]) * 6), anchor: .center)
                                    
                                    HandView(length: 35, thickness: 8, color: .white)
                                        .rotationEffect(.degrees((Double(alarms.hourList[index]) * 30) + (Double(alarms.minList[index]) / 2)), anchor: .center)
                                }
                                .frame(width: 150, height: 150)
                            }
                        } header: {
                            Text("Alarm \(alarms.idList[index]) (\(alarms.primaryList[index]))")
                                .foregroundStyle(mode == "Dark" ? Color.gray : Color.white)
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .listRowBackground(alarms.mornList[index] == "Morning" ?
                                           LinearGradient(gradient: Gradient(colors: mornGradColors),
                                                          startPoint: .top,
                                                          endPoint: .bottom)
                                            .animation(.easeInOut(duration: 3), value: mornGradColors)
                                           :
                                            LinearGradient(gradient: Gradient(colors: nightGradColors),
                                                           startPoint: .top,
                                                           endPoint: .bottom)
                                            .animation(.easeInOut(duration: 3), value: nightGradColors)
                        )
                    }
                    .onAppear {
                        animateGradientMorn()
                        animateGradientNight()
                    }
                    
                    Section {
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
                        Button("Add Alarm") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                alarms.idList.append(alarms.idList.count + 1)
                                alarms.secList.append(sec)
                                alarms.minList.append(min)
                                alarms.hourList.append(hour)
                                alarms.dayList.append(day)
                                
                                if alarms.idList.count > 1 && (alarms.diffList.last! < 60 || alarms.diffList.last! > 600) {
                                    alarms.removeLastAll()
                                    alertBool = true
                                } else {
                                    PersistenceController.shared.saveAlarmList(alarms: alarms)
                                }
                            }
                        }
                    } header: {
                        Text("Add new alarm")
                            .foregroundStyle(mode == "Dark" ? Color.gray : Color.white)
                    }
                    
                    
                }
                .navigationTitle("Alarms")
                .scrollContentBackground(.hidden) // Hide form background
            }
            .introspect(.navigationStack, on: .iOS(.v16...)) {
                $0.viewControllers.forEach { controller in
                    controller.view.backgroundColor = .clear
                }
            }
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
