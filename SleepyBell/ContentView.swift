//
//  ContentView.swift
//  SleepyBell
//
//  Created by JoeyHammoth on 1/31/25.
//

import SwiftUI

/// A view modifier that applies a global custom font to any view.
///
/// This modifier takes a font name and size and applies a custom font style to the modified view. It is used
/// together with the `globalFont` extension on `View` to provide a concise way to change fonts globally.
struct GlobalFontModifier: ViewModifier {
    
    /// The name of the custom font to apply.
    let fontString: String
    
    /// The size of the custom font.
    let fSize: CGFloat
    
    /// Applies the custom font to the given content view.
    ///
    /// - Parameter content: The original view that this modifier is being applied to.
    /// - Returns: A view with the custom font applied.
    func body(content: Content) -> some View {
        content.font(.custom(fontString, size: fSize))
    }
    
}

extension View {
    /// Applies a global custom font to the view.
    ///
    /// This convenience method applies the `GlobalFontModifier` with the specified font name and size.
    ///
    /// - Parameters:
    ///   - font: The name of the custom font to apply.
    ///   - fontSize: The size of the custom font.
    /// - Returns: A view modified to display the custom font.
    func globalFont(font: String, fontSize: CGFloat) -> some View {
        self.modifier(GlobalFontModifier(fontString: font, fSize: fontSize))
    }
    
}

extension View {
    
    /// Conditionally transforms the view based on a given condition.
    ///
    /// If the provided `condition` evaluates to `true`, the view is transformed using the given `transform` closure.
    /// Otherwise, the view is returned without any changes.
    ///
    /// - Parameters:
    ///   - condition: A Boolean value that determines whether to apply the transformation.
    ///   - transform: A closure that takes the original view and returns a modified view.
    /// - Returns: Either the transformed view (if `condition` is `true`) or the original view.
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
}

/// The primary view for the SleepyBell application.
///
/// This view manages the display of the current time, day/night toggle, action buttons for stats, alarms,
/// settings, and notifications, and conditionally shows various overlay views. It also handles alarm triggering,
/// updating the UI based on the current time, and persisting alert states.
struct ContentView: View {
    // MARK: - State Variables
    
    /// The number of stars displayed in the background (used for visual effects in the day/night toggle).
    @State private var starNum: Int = 100
    
    /// A Boolean flag that determines whether the statistics view is visible.
    @State private var showStats = false
    
    /// A Boolean flag that determines whether the notifications view is visible.
    @State private var showNotifications = false
    
    /// A Boolean flag that determines whether the settings view is visible.
    @State private var showSettings = false
    
    /// A Boolean flag that determines whether the alarm form view is visible.
    @State private var showForm = false
    
    /// A string indicating the current day or night state ("AM" or "PM").
    @State private var selectedDayNight: String = "AM"
    
    /// A string representing the current time (formatted).
    @State private var currentTime: String = ""
    
    /// A string representing the current UI mode ("Dark" for dark mode; any other value defaults to light mode).
    @State private var darkMode: String = "Dark"
    
    /// A Boolean flag used to trigger an alert when an improper secondary alarm is set.
    @State private var alert: Bool = false
    
    /// A list of alarms retrieved from persistent storage or an external source.
    @State private var alarmArr: AlarmList = fetchLatestAlarm()
    
    /// A dictionary mapping sound identifiers to their configurations, retrieved from persistent storage.
    @State private var soundHM: [String:String] = fetchLatestSoundDict()
    
    /// A Boolean flag to confirm the deletion of all alarms, notifications, and sleep data.
    @State private var clearAlert: Bool = false
    
    /// A Boolean flag that presents a notification alert when an alarm is triggered.
    @State private var notiAlertBool: Bool = false
    
    /// A string representing the current alarm label associated with a notification alert.
    @State private var notiAlertCurr: String = ""
    
    /// A list of recorded wake-up times retrieved from persistent storage.
    @State private var wokeTimeList: [String] = fetchLatestAlarmWakeList()
    
    /// A list of recorded sleep times retrieved from persistent storage.
    @State private var sleepTimeList: [String] = fetchLatestAlarmSleepList()
    
    /// A list of dates corresponding to the recorded wake-up times.
    @State private var wokeTimeDateList: [String] = fetchLatestAlarmWakeDateList()
    
    /// A list of dates corresponding to the recorded sleep times.
    @State private var sleepTimeDateList: [String] = fetchLatestAlarmSleepDateList()
    
    /// A dictionary mapping alarm labels to the number of times they have been triggered.
    @State private var alarmModeDict: [String:Int] = fetchLatestAlarmModeList()
    
    /// The selected custom font name for the global font change feature.
    @State private var selectedFont: String = "Helvetica Neue"
    
    /// The size of the selected custom font.
    @State private var selectedFontSize: CGFloat = 16
    
    /// A Boolean flag that enables or disables the global font change feature.
    @State private var enableFontChange: Bool = false
    
    // MARK: - View Body
    
    /// The content and layout of the main view.
    ///
    /// The view is composed of a background (with a day/night toggle), a header displaying the app name and current time,
    /// a row of action buttons for statistics, alarms, settings, notifications, and a link to the GitHub repository.
    /// It also conditionally presents overlay views (such as the alarm form, settings, notifications, and statistics)
    /// based on user interaction.
    var body: some View {
        ZStack {
            
            // Background view displaying stars and a day/night toggle.
            DayNightToggleView(isNight: selectedDayNight == "AM" ? false : true, stars: $starNum)
            
            VStack {
                // App title
                Text("SleepyBell")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                    .padding()
                
                // Current time display with animation and transition.
                Text(currentTime)
                    .font(.system(size: 60))
                    .padding()
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.5), value: currentTime)
                    .foregroundColor(.white)
                    
                Spacer()
                
                // Row of action buttons.
                HStack {
                    // Button to toggle the statistics view.
                    Button(action: {
                        withAnimation {
                            showStats.toggle()
                        }
                    }) {
                        Image(systemName: "chart.xyaxis.line") // Use a system image for the alarm icon
                            .resizable()
                            .frame(width: 24, height: 24) // Set the size of the icon
                            .foregroundColor(.black) // Set the icon color
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .clipShape(Capsule())
                            .shadow(radius: 5)
                    }
                    // Button to toggle the alarm form view.
                    Button(action: {
                        withAnimation {
                            showForm.toggle()
                        }
                    }) {
                        Image(systemName: "alarm.fill") // Use a system image for the alarm icon
                            .resizable()
                            .frame(width: 24, height: 24) // Set the size of the icon
                            .foregroundColor(.black) // Set the icon color
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .clipShape(Capsule())
                            .shadow(radius: 5)
                    }
                    // Button to toggle the settings view.
                    Button(action: {
                        withAnimation {
                            showSettings.toggle()
                        }
                    }) {
                        Image(systemName: "gearshape.2") // Use a system image for the alarm icon
                            .resizable()
                            .frame(width: 30, height: 24) // Set the size of the icon
                            .foregroundColor(.black) // Set the icon color
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .clipShape(Capsule())
                            .shadow(radius: 5)
                    }
                    // Button to toggle the notifications view.
                    Button(action: {
                        withAnimation {
                            showNotifications.toggle()
                        }
                    }) {
                        Image(systemName: "bell.fill") // Use a system image for the alarm icon
                            .resizable()
                            .frame(width: 24, height: 24) // Set the size of the icon
                            .foregroundColor(.black) // Set the icon color
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .clipShape(Capsule())
                            .shadow(radius: 5)
                    }
                    // Button to open the GitHub repository URL.
                    Button(action: {
                        withAnimation {
                            if let url = URL(string: "https://github.com/JoeyHammoth/SleepyBell") {
                                            UIApplication.shared.open(url)
                                        }
                        }
                    }) {
                        Image(systemName: "network") // Use a system image for the alarm icon
                            .resizable()
                            .frame(width: 24, height: 24) // Set the size of the icon
                            .foregroundColor(.black) // Set the icon color
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .clipShape(Capsule())
                            .shadow(radius: 5)
                    }
                }
                // License or developer information.
                Text("JoeyHammoth MIT License")
                    .font(.system(size: 15, weight: .bold))
                    .padding()
            }
            // alert for wrong alarm
            .alert(isPresented: $alert) {
                Alert(title: Text("Improper Secondary Alarm!"),
                      message: Text("Please choose a secondary alarm time that is between 1 and 10 minutes more than your last alarm."),
                      dismissButton: .default(Text("OK")))
            }
            // alert for removing all alarms
            .alert("Warning", isPresented: $clearAlert) {
                Button("Yes") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        alarmArr.removeEverything()
                    }
                    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                    soundHM.removeAll()
                    PersistenceController.shared.deleteAll()
                    // Remove all data from UserDefaults (notification alerts)
                    if let domain = Bundle.main.bundleIdentifier {
                        UserDefaults.standard.removePersistentDomain(forName: domain)
                        UserDefaults.standard.synchronize() // Ensures changes are saved immediately
                    }
                    clearAlert = false
                }
                Button("No") {
                    clearAlert = false
                }
            } message: {
                Text("Deleting everything means deleting all alarms, scheduled notifications and sleep data. Are you sure you want to do this?")
            }
            // Alert for notifying the user when an alarm is triggered.
            .alert("Alarm is Off!", isPresented: $notiAlertBool) {
                let now = Calendar.current.dateComponents([.year, .month, .day], from: Date())
                let todayString = "\(now.year!)-\(now.month!)-\(now.day!)"
                
                var wokeTimeDateListCpy = wokeTimeDateList
                var sleepTimeDateListCpy = sleepTimeDateList
                var wokeTimeListCpy = wokeTimeList
                var alarmModeDictCpy = alarmModeDict
                var sleepTimeListCpy = sleepTimeList
                Button("Yes") {
                    // User confirms that they woke up.
                    wokeTimeListCpy.append(notiAlertCurr)
                    wokeTimeDateListCpy.append(todayString)
                    if alarmModeDictCpy[notiAlertCurr] != nil {
                        alarmModeDictCpy[notiAlertCurr] = alarmModeDictCpy[notiAlertCurr]! + 1
                    } else {
                        alarmModeDictCpy[notiAlertCurr] = 1
                    }
                    PersistenceController.shared.saveStats(sleepList: sleepTimeListCpy, wakingList: wokeTimeListCpy, modesDict: alarmModeDictCpy, sleepDateList: sleepTimeDateListCpy, wakingDateList: wokeTimeDateListCpy)
                    wokeTimeList = fetchLatestAlarmWakeList()
                    alarmModeDict = fetchLatestAlarmModeList()
                    wokeTimeDateList = fetchLatestAlarmWakeDateList()
                    sleepTimeDateList = fetchLatestAlarmSleepDateList()
                }
                Button("No") {
                    // User confirms that they did not wake up (returned to sleep).
                    sleepTimeListCpy.append(notiAlertCurr)
                    sleepTimeDateListCpy.append(todayString)
                    if alarmModeDictCpy[notiAlertCurr] != nil {
                        alarmModeDictCpy[notiAlertCurr] = alarmModeDictCpy[notiAlertCurr]! + 1
                    } else {
                        alarmModeDictCpy[notiAlertCurr] = 1
                    }
                    PersistenceController.shared.saveStats(sleepList: sleepTimeListCpy, wakingList: wokeTimeListCpy, modesDict: alarmModeDictCpy, sleepDateList: sleepTimeDateListCpy, wakingDateList: wokeTimeDateListCpy)
                    sleepTimeList = fetchLatestAlarmSleepList()
                    alarmModeDict = fetchLatestAlarmModeList()
                    wokeTimeDateList = fetchLatestAlarmWakeDateList()
                    sleepTimeDateList = fetchLatestAlarmSleepDateList()
                }
            } message: {
                Text("This is the alarm for \(notiAlertCurr). Did you wake up?")
            }
            .onAppear() {
                updateCurrentTime()
                checkMissedAlerts()
                startTimer()
            }
            .onChange(of: darkMode) {
                // Switch the color scheme based on darkMode state
                if darkMode == "Dark" {
                    // Use UIWindowScene to change the user interface style for iOS 15+
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        windowScene.windows.first?.rootViewController?.overrideUserInterfaceStyle = .dark
                    }
                } else {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        windowScene.windows.first?.rootViewController?.overrideUserInterfaceStyle = .light
                    }
                }
            }
            .preferredColorScheme(darkMode == "Dark" ? .dark : .light)
            
            // Conditionally display the overlay views based on user interactions.
            if showForm {
                DraggableTransparentForm(mode: $darkMode, showForm: $showForm, alertBool: $alert, alarms: $alarmArr, clearAlertBool: $clearAlert, soundDict: $soundHM)
            }
            
            if showSettings {
                Settings(starAmount: $starNum, showForm: $showSettings, mode: $darkMode, font: $selectedFont, size: $selectedFontSize, enableChangeFont: $enableFontChange)
            }
            
            if showNotifications {
                Notifications(showForm: $showNotifications, mode: $darkMode, soundDict: $soundHM, occurencesDict: $alarmModeDict)
            }
            
            if showStats {
                Statistics(showForm: $showStats, sleepDateList: $sleepTimeDateList, wakeDateList: $wokeTimeDateList, sleepList: $sleepTimeList, wakeList: $wokeTimeList)
            }
        }
        .if(enableFontChange) { view in
            view.globalFont(font: selectedFont, fontSize: selectedFontSize)
        }
        .onAppear() {
            requestNotificationPermission()
        }
    }
    
    // MARK: - Timer and Alert Methods
    
    /// Starts a timer that updates the current time every second and checks for scheduled alarms.
    ///
    /// This method creates a repeating timer that fires every second. On each tick, it updates the displayed time
    /// and checks if any alarm is scheduled to trigger at the current moment.
    func startTimer() {
        // Update the current time every second
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            updateCurrentTime()
            checkAndTriggerAlert()
        }
    }
    
    
    /// Checks all scheduled alarms to see if any should trigger an alert.
    ///
    /// The function iterates through the list of alarms, converts the scheduled time (with special handling
    /// for a 24-hour edge case), and compares it with the current time. If the times match and the alert has not
    /// already been triggered, it presents the notification alert and records that the alarm has been triggered.
    func checkAndTriggerAlert() {
        let now = Calendar.current.dateComponents([.hour, .minute, .second], from: Date())

        for i in 0..<alarmArr.idList.count {
            var realHour: Int {
                if alarmArr.realHourList[i] == 24 {
                    return 0
                } else {
                    return alarmArr.realHourList[i]
                }
            }
            
            let scheduledHour = realHour
            let scheduledMinute = alarmArr.minList[i]
            let scheduledSecond = alarmArr.secList[i]
            
            let scheduledTimeString = "\(scheduledHour):\(scheduledMinute):\(scheduledSecond)"
            
            if scheduledHour == now.hour &&
               scheduledMinute == now.minute &&
               scheduledSecond == now.second &&
               !hasAlertBeenTriggered(for: scheduledTimeString) {
                notiAlertBool = true
                notiAlertCurr = alarmArr.layout[i]
                saveTriggeredAlert(for: scheduledTimeString)
                break
            }
        }
    }
    
    /// Checks for any missed alarms when the application launches.
    ///
    /// This method iterates through the list of alarms and compares each scheduled time with the current time.
    /// If an alarm's scheduled time has already passed and it hasn't been triggered yet, the function triggers the alert.
    private func checkMissedAlerts() {
        let now = Calendar.current.dateComponents([.hour, .minute, .second], from: Date())

        for i in 0..<alarmArr.idList.count {
            var realHour: Int {
                if alarmArr.realHourList[i] == 24 {
                    return 0
                } else {
                    return alarmArr.realHourList[i]
                }
            }
            
            let scheduledHour = realHour
            let scheduledMinute = alarmArr.minList[i]
            let scheduledSecond = alarmArr.secList[i]
            
            let scheduledTimeString = "\(scheduledHour):\(scheduledMinute):\(scheduledSecond)"
            
            if hasAlertBeenTriggered(for: scheduledTimeString) {
                continue // Skip if already triggered
            }
            
            // Check if the scheduled time has passed
            if (scheduledHour < now.hour!) ||
               (scheduledHour == now.hour! && scheduledMinute < now.minute!) ||
               (scheduledHour == now.hour! && scheduledMinute == now.minute! && scheduledSecond <= now.second!) {
                notiAlertBool = true
                notiAlertCurr = alarmArr.layout[i]
                saveTriggeredAlert(for: scheduledTimeString)
                break
            }
        }
    }

    // MARK: - Persistent Alert Tracking Methods
    
    /// Saves the triggered alarm time to persistent storage.
    ///
    /// This method appends the time string of the triggered alarm to an array stored in `UserDefaults` under the key
    /// `"TriggeredAlerts"`. This is used to prevent the same alarm from triggering multiple times.
    ///
    /// - Parameter time: A string representing the time at which the alarm was triggered.
    private func saveTriggeredAlert(for time: String) {
        var triggeredAlerts = UserDefaults.standard.array(forKey: "TriggeredAlerts") as? [String] ?? []
        triggeredAlerts.append(time)
        UserDefaults.standard.set(triggeredAlerts, forKey: "TriggeredAlerts")
    }

    
    /// Checks whether an alarm at a specific time has already been triggered.
    ///
    /// The function retrieves the list of previously triggered alarms from `UserDefaults` and checks if the given time
    /// string is present.
    ///
    /// - Parameter time: A string representing the alarm time to check.
    /// - Returns: `true` if the alarm has already been triggered; otherwise, `false`.
    private func hasAlertBeenTriggered(for time: String) -> Bool {
        let triggeredAlerts = UserDefaults.standard.array(forKey: "TriggeredAlerts") as? [String] ?? []
        return triggeredAlerts.contains(time)
    }
    
    /// Resets the list of triggered alarms if a new day has begun.
    ///
    /// This function checks the last reset date stored in `UserDefaults` against the current date. If they do not match,
    /// the list of triggered alarms is cleared and the current date is saved as the last reset date.
    private func resetAlertsForNewDay() {
        let now = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        let todayString = "\(now.year!)-\(now.month!)-\(now.day!)"

        let lastReset = UserDefaults.standard.string(forKey: "LastResetDate") ?? ""

        if lastReset != todayString {
            UserDefaults.standard.set([], forKey: "TriggeredAlerts") // Clear previous alerts
            UserDefaults.standard.set(todayString, forKey: "LastResetDate") // Store today's date
        }
    }
    
    // MARK: - Time Update Method
    
    /// Updates the current time string and adjusts the day/night mode.
    ///
    /// This method uses a `DateFormatter` to format the current time in a 12-hour format (with AM/PM)
    /// and updates the `currentTime` state variable. It also sets the `selectedDayNight` variable based on the hour.
    func updateCurrentTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm:ss a"  // 12-hour format with AM/PM
        let currentDate = Date()
        currentTime = formatter.string(from: currentDate)  // Get the current time as string
        
        // Check the hour and set AM/PM
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: currentDate)
        
        // Set selectedDayNight based on the hour
        if hour >= 18 || hour < 6 {  // Between 6 PM and 6 AM
            selectedDayNight = "PM"
        } else {  // Between 6 AM and 6 PM
            selectedDayNight = "AM"
        }
    }
}

#Preview {
    ContentView()
}
