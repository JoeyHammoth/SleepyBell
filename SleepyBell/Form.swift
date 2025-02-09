//
//  Form.swift
//  SleepyBell
//
//  Created by JoeyHammoth on 1/31/25.
//

import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import AVFoundation

// MARK: - HandView

/// A view that represents a clock hand.
///
/// The `HandView` renders a colored rectangle with a specified length and thickness.
/// It is offset vertically so that its bottom edge aligns at the center of its container,
/// making it ideal for use as a clock hand on a circular dial.
struct HandView: View {
    
    /// The vertical length of the hand.
    let length: CGFloat
    
    /// The horizontal thickness of the hand.
    let thickness: CGFloat
    
    /// The color of the hand. Defaults to white.
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
    /// The body of the view creates a rectangle filled with the specified color and sized according to
    /// the provided `length` and `thickness`. The rectangle is offset vertically by half its length to
    /// align its bottom edge to the center of the container.
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: thickness, height: length)
            .offset(y: -length / 2)  // Align bottom at center
    }
}

// MARK: - AlarmList

/// A model that represents a list of alarms.
///
/// `AlarmList` holds arrays for alarm identifiers and time components (seconds, minutes, hours, and AM/PM).
/// It provides computed properties for generating formatted labels, converting hours to a 24-hour format,
/// classifying alarms as morning or night, calculating time differences between alarms, and producing a
/// formatted layout string for display.
struct AlarmList {
    /// An array of alarm identifiers.
    var idList: [Int] = []
    
    /// A computed array of alarm type labels.
    ///
    /// The first alarm is labeled "Primary" and subsequent alarms are labeled "Secondary".
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
    
    /// An array of seconds for each alarm.
    var secList: [Int] = []
    
    /// An array of minutes for each alarm.
    var minList: [Int] = []
    
    /// An array of hours for each alarm.
    var hourList: [Int] = []
    
    /// An array of day indicators ("AM"/"PM") for each alarm.
    var dayList: [String] = []
    
    /// A computed array of converted hours in 24-hour format.
    ///
    /// For each alarm, if the day is "AM" and the hour is 12, it is converted to 24;
    /// otherwise, for "PM" the hour is increased by 12 (unless it's 12 already).
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
    
    /// A computed array classifying each alarm as "Morning" or "Night".
    ///
    /// An alarm is considered "Morning" if its converted hour is between 6 (inclusive) and 18 (exclusive);
    /// otherwise, it is considered "Night".
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
    
    /// A computed array of time differences (in seconds) between consecutive alarms.
    ///
    /// For the first alarm, the difference is 0. For subsequent alarms, the difference is calculated based on
    /// the difference in hours, minutes, and seconds between the current and previous alarm.
    var diffList: [Int] {
        var diffArr: [Int] = []
        var hourDiff: Int = 0
        var minDiff: Int = 0
        var secDiff: Int = 0
        
        for i in 0..<idList.count {
            if i == 0 {
                diffArr.append(0)
            } else {
                if realHourList[i-1] == 24 {
                    hourDiff = (realHourList[i] - 0) * 3600
                } else {
                    hourDiff = (realHourList[i] - realHourList[i-1]) * 3600
                }
                minDiff = (minList[i] - minList[i-1]) * 60
                secDiff = secList[i] - secList[i-1]
                diffArr.append(hourDiff + minDiff + secDiff)
            }
        }
        return diffArr
    }
    
    /// A computed array that returns formatted time strings for each alarm.
    ///
    /// The time is formatted with appropriate zero padding for hours, minutes, and seconds.
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
    
    /// Removes the last alarm entry from all alarm arrays.
    mutating func removeLastAll() {
        idList.removeLast()
        secList.removeLast()
        minList.removeLast()
        hourList.removeLast()
        dayList.removeLast()
    }
    
    /// Clears all alarms from all arrays.
    mutating func removeEverything() {
        idList.removeAll()
        secList.removeAll()
        minList.removeAll()
        hourList.removeAll()
        dayList.removeAll()
    }
}

// MARK: - DraggableTransparentForm

/// A draggable, transparent form view for managing alarms and audio settings.
///
/// The `DraggableTransparentForm` provides the following functionality:
/// - Displays an "About" section explaining the alarm system.
/// - Lists all currently set alarms with a clock face representation.
/// - Allows the user to add new alarms by selecting time components and an alarm sound.
/// - Integrates an audio player to preview alarm sounds.
/// - Provides a section for deleting all alarms.
/// - Supports drag gestures to dismiss the form by sliding it vertically.
///
/// The view uses gradient animations for visual feedback and leverages SwiftUIIntrospect to customize the
/// background of the navigation stack.
struct DraggableTransparentForm: View {
    
    // MARK: - Static Data
    
    /// List of day/night options.
    let dayNightList = ["AM", "PM"]
    
    /// List of alarm type options.
    let primList = ["Primary", "Secondary"]
    
    /// List of available alarm sounds.
    let soundList = ["lottery", "alert", "classic", "morning", "rooster"]
    
    // MARK: - Bindings
    
    /// The current mode (e.g., light/dark) of the application.
    @Binding var mode: String
    
    /// A binding that indicates whether the form is currently shown.
    @Binding var showForm: Bool
    
    /// A binding used to trigger an alert if a new alarm is not set properly.
    @Binding var alertBool: Bool
    
    /// A binding to the list of alarms.
    @Binding var alarms: AlarmList
    
    /// A binding used to trigger an alert to confirm deletion of all alarms.
    @Binding var clearAlertBool: Bool
    
    /// A binding to a dictionary mapping sound names to their configurations.
    @Binding var soundDict: [String:String]
    
    // MARK: - State Properties (Drag & Layout)
    
    /// The vertical offset for the form view, used to position the form off-screen initially.
    @State private var offsetY: CGFloat = 400
    
    /// Stores the last offset value to prevent abrupt jumps during dragging.
    @State private var lastOffset: CGFloat = 400
    
    /// The dynamic drag offset during user interaction.
    @State private var dragOffset: CGFloat = 0
    
    // MARK: - Temporary Alarm Settings
    
    /// The selected seconds for the new alarm.
    @State private var sec: Int = 0
    
    /// The selected minutes for the new alarm.
    @State private var min: Int = 0
    
    /// The selected hour for the new alarm.
    @State private var hour: Int = 1
    
    /// The selected day indicator ("AM" or "PM") for the new alarm.
    @State private var day: String = "AM"
    
    /// The selected alarm sound.
    @State private var sound: String = "lottery"
    
    // MARK: - Gradient Colors for Alarm Cells
    
    /// The gradient colors used for morning alarms.
    @State private var mornGradColors: [Color] = [Color.cyan, Color.white]
    
    /// The gradient colors used for night alarms.
    @State private var nightGradColors: [Color] = [Color.black.opacity(0.5), Color.blue.opacity(0.5)]
    
    // MARK: - Audio Player State
    
    /// The audio player used for playing alarm sounds.
    @State private var audioPlayer: AVAudioPlayer?
    
    /// A Boolean indicating whether the audio is currently playing.
    @State private var isPlaying = false
    
    /// The current playback time of the audio.
    @State private var currentTime: TimeInterval = 0
    
    /// The total duration of the audio track.
    @State private var duration: TimeInterval = 1
    
    /// A timer used to update the playback progress.
    @State private var timer: Timer?
    
    // MARK: - Gradient Animation Functions
    
    /// Animates the gradient colors for morning alarms.
    ///
    /// A timer is scheduled to update `mornGradColors` every 5 seconds, simulating a transition from morning to noon and back.
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
    
    /// Animates the gradient colors for night alarms.
    ///
    /// A timer is scheduled to update `nightGradColors` every 5 seconds, simulating a transition in the evening ambiance.
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
    
    // MARK: - Audio Player Setup and Controls
    
    /// Sets up the audio player with the specified sound file.
    ///
    /// The function attempts to load a `.wav` file from the app bundle, configures the audio session,
    /// and prepares the audio player. If the file is not found or an error occurs, an error message is printed.
    ///
    /// - Parameter filename: The name of the audio file (without extension).
    func setupAudio(filename: String) {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "wav") else {
            print("Audio file not found")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            duration = audioPlayer?.duration ?? 1
            currentTime = 0
            
            // Stop previous playback when switching sounds
            isPlaying = false
            stopTimer()
            
            // Set up audio session for physical devices
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
        } catch {
            print("Error loading audio: \(error.localizedDescription)")
        }
    }
    
    /// Plays or pauses the audio.
    ///
    /// If the audio is currently playing, it pauses the playback and stops the progress timer.
    /// If the audio is paused, it resumes playback and starts the progress timer.
    func playSound() {
        guard let player = audioPlayer else { return }
        if isPlaying {
            player.pause()
            stopTimer()
        } else {
            player.play()
            startTimer()
        }
        isPlaying.toggle()
    }
    
    /// Stops the audio playback.
    ///
    /// The function stops the audio, resets the playback time, and stops the progress timer.
    func stopSound() {
        guard let player = audioPlayer else { return }
        player.stop()
        player.currentTime = 0
        currentTime = 0
        isPlaying = false
        stopTimer()
    }
    
    /// Seeks the audio playback to a specified time.
    ///
    /// - Parameter time: The time (in seconds) to seek to.
    func seekToTime(_ time: TimeInterval) {
        guard let player = audioPlayer else { return }
        player.currentTime = time
        if isPlaying {
            player.play()
        }
    }
    
    /// Starts a timer to update the audio playback progress.
    ///
    /// The timer fires every 0.1 seconds, updating the `currentTime` property with the audio player's current time.
    func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if let player = audioPlayer {
                currentTime = player.currentTime
            }
        }
    }
    
    /// Stops the audio progress update timer.
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    /// Formats a time interval into a string of the format "MM:SS".
    ///
    /// - Parameter time: The time interval to format.
    /// - Returns: A formatted time string.
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - View Body
    
    /// The content and layout of the draggable transparent form.
    ///
    /// The form is composed of multiple sections:
    /// - **About:** A description of the alarm functionality.
    /// - **Alarms List:** A list of current alarms with a clock face representation.
    /// - **Add New Alarm:** Controls for configuring and adding a new alarm, including time pickers, alarm sound selection,
    ///   and an audio player interface.
    /// - **Remove All Alarms:** A button to delete all alarms.
    ///
    /// The view supports drag gestures to dismiss the form by sliding it vertically.
    var body: some View {
        VStack {
            // A visual drag handle at the top of the form.
            Capsule()
                .frame(width: 50, height: 5)
                .foregroundColor(.gray.opacity(0.8))
                .padding(5)
            
            // The main content is wrapped in a NavigationStack.
            NavigationStack {
                Form {
                    // MARK: About Section
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
                            .foregroundStyle(Color.white)
                            .fontWeight(.bold)
                    }
                    
                    // MARK: Alarms List Section
                    ForEach(0..<alarms.idList.count, id: \.self) { index in
                        Section {
                            HStack {
                                // Display the formatted alarm time.
                                Text(alarms.layout[index])
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundStyle(Color.white)
                                Spacer()
                                // A clock face representation using overlapping circles and clock hands.
                                ZStack {
                                    Circle()
                                        .stroke(lineWidth: 5)
                                        .padding(8)
                                        .foregroundColor(Color.white)
                                    
                                    // Second hand: rotates 6° per second.
                                    HandView(length: 60, thickness: 3, color: .white)
                                        .rotationEffect(.degrees(Double(alarms.secList[index]) * 6), anchor: .center)
                                    
                                    // Minute hand: rotates 6° per minute.
                                    HandView(length: 50, thickness: 6, color: .white)
                                        .rotationEffect(.degrees(Double(alarms.minList[index]) * 6), anchor: .center)
                                    
                                    // Hour hand: rotates 30° per hour, with an additional rotation based on the minutes.
                                    HandView(length: 35, thickness: 8, color: .white)
                                        .rotationEffect(.degrees((Double(alarms.hourList[index]) * 30) + (Double(alarms.minList[index]) / 2)), anchor: .center)
                                }
                                .frame(width: 150, height: 150)
                            }
                        } header: {
                            Text("Alarm \(alarms.idList[index]) (\(alarms.primaryList[index]))")
                                .foregroundStyle(Color.white)
                                .fontWeight(.bold)
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                        // Set the background gradient based on whether the alarm is in the morning or at night.
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
                    
                    // MARK: Add New Alarm Section
                    Section {
                        // Pickers for selecting the time components of the new alarm.
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
                        
                        // Picker for selecting the alarm sound.
                        Picker("Alarm Sound", selection: $sound) {
                            ForEach(soundList, id: \.self) {
                                Text($0)
                            }
                        }
                        
                        // Audio Player controls for previewing the selected alarm sound.
                        VStack {
                            // Slider showing audio playback progress.
                            Slider(value: $currentTime, in: 0...duration, onEditingChanged: { isEditing in
                                if !isEditing {
                                    seekToTime(currentTime)
                                }
                            })
                            .padding()
                            
                            // Display the current time and total duration.
                            HStack {
                                Text(formatTime(currentTime))
                                Spacer()
                                Text(formatTime(duration))
                            }
                            .font(.caption)
                            .padding(.horizontal)
                            
                            // Play and Stop buttons for the audio player.
                            HStack {
                                Button(action: playSound) {
                                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                        .font(.largeTitle)
                                        .padding()
                                }
                                .buttonStyle(.plain)
                                
                                Button(action: stopSound) {
                                    Image(systemName: "stop.fill")
                                        .font(.largeTitle)
                                        .padding()
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .onAppear {
                            setupAudio(filename: sound)
                        }
                        .onChange(of: sound) {
                            setupAudio(filename: sound)
                        }
                        .contentShape(Rectangle())
                        .allowsHitTesting(true)
                        
                        // Button to add a new alarm.
                        Button("Add Alarm") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                alarms.idList.append(alarms.idList.count + 1)
                                alarms.secList.append(sec)
                                alarms.minList.append(min)
                                alarms.hourList.append(hour)
                                alarms.dayList.append(day)
                                
                                // Validate the time difference for secondary alarms.
                                if alarms.idList.count > 1 && (alarms.diffList.last! < 60 || alarms.diffList.last! > 600) {
                                    alarms.removeLastAll()
                                    alertBool = true
                                } else {
                                    PersistenceController.shared.saveAlarmList(alarms: alarms)
                                    scheduleNotification(id: alarms.layout.last!, alarms: alarms, index: alarms.idList.count - 1, filename: sound + ".wav", soundList: &soundDict)
                                    PersistenceController.shared.saveNotificationSounds(soundDict: soundDict)
                                }
                            }
                        }
                    } header: {
                        Text("Add new alarm")
                            .foregroundStyle(Color.white)
                            .fontWeight(.bold)
                    }
                    
                    // MARK: Remove All Alarms Section
                    Section {
                        Button("Delete Alarms") {
                            clearAlertBool = true
                        }
                        .foregroundStyle(Color.red)
                    } header: {
                        Text("Remove all alarms")
                            .foregroundStyle(Color.white)
                            .fontWeight(.bold)
                    }
                    
                }
                .navigationTitle("Alarms")
                .scrollContentBackground(.hidden) // Hide the default form background.
            }
            .introspect(.navigationStack, on: .iOS(.v16...)) {
                $0.viewControllers.forEach { controller in
                    controller.view.backgroundColor = .clear
                }
            }
        }
        // Expand to fill the entire available space.
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // Apply a transparent blur effect as the background.
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
        // Apply a combined offset from the base offset and the current drag gesture.
        .offset(y: offsetY + dragOffset)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    // Update the drag offset as the user moves the form.
                    dragOffset = gesture.translation.height
                }
                .onEnded { _ in
                    let newOffset = offsetY + dragOffset
                    
                    if newOffset > 250 {  // Dismiss the form if dragged down sufficiently.
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            offsetY = UIScreen.main.bounds.height
                            showForm = false
                        }
                    } else {  // Otherwise, snap the form back into position.
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            offsetY = 0
                        }
                    }
                    
                    // Reset the drag offset after the gesture ends.
                    dragOffset = 0
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
