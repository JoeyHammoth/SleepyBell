//
//  ContentView.swift
//  SleepyBell
//
//  Created by JoeyHammoth jon 1/31/25.
//

import SwiftUI

// For changing fonts
struct GlobalFontModifier: ViewModifier {
    let fontString: String
    let fSize: CGFloat
    func body(content: Content) -> some View {
        content.font(.custom(fontString, size: fSize))
    }
}

extension View {
    func globalFont(font: String, fontSize: CGFloat) -> some View {
        self.modifier(GlobalFontModifier(fontString: font, fSize: fontSize))
    }
}

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

struct ContentView: View {
    @State private var starNum: Int = 100
    @State private var showStats = false
    @State private var showNotifications = false
    @State private var showSettings = false
    @State private var showForm = false
    @State private var selectedDayNight: String = "AM"
    @State private var currentTime: String = ""
    @State private var darkMode: String = "Dark"
    @State private var alert: Bool = false
    @State private var alarmArr: AlarmList = fetchLatestAlarm()
    @State private var soundHM: [String:String] = fetchLatestSoundDict()
    
    @State private var clearAlert: Bool = false
    @State private var notiAlertBool: Bool = false
    @State private var notiAlertCurr: String = ""
    
    @State private var wokeTimeList: [String] = fetchLatestAlarmWakeList()
    @State private var sleepTimeList: [String] = fetchLatestAlarmSleepList()
    @State private var wokeTimeDateList: [String] = fetchLatestAlarmWakeDateList()
    @State private var sleepTimeDateList: [String] = fetchLatestAlarmSleepDateList()
    @State private var alarmModeDict: [String:Int] = fetchLatestAlarmModeList()
    
    @State private var selectedFont: String = "Helvetica Neue"
    @State private var selectedFontSize: CGFloat = 16
    @State private var enableFontChange: Bool = false
    
    var body: some View {
        ZStack {
            DayNightToggleView(isNight: selectedDayNight == "AM" ? false : true, stars: $starNum)
            
            VStack {
                Text("SleepyBell")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                    .padding()
                
                Text(currentTime)
                    .font(.system(size: 60))
                    .padding()
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.5), value: currentTime)
                    .foregroundColor(.white)
                    
                Spacer()
                HStack {
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
            // notification alerts
            .alert("Alarm is Off!", isPresented: $notiAlertBool) {
                let now = Calendar.current.dateComponents([.year, .month, .day], from: Date())
                let todayString = "\(now.year!)-\(now.month!)-\(now.day!)"
                
                var wokeTimeDateListCpy = wokeTimeDateList
                var sleepTimeDateListCpy = sleepTimeDateList
                var wokeTimeListCpy = wokeTimeList
                var alarmModeDictCpy = alarmModeDict
                var sleepTimeListCpy = sleepTimeList
                Button("Yes") {
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
    
    func startTimer() {
        // Update the current time every second
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            updateCurrentTime()
            checkAndTriggerAlert()
        }
    }
    
    /// Checks if a scheduled time is reached
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

    /// Checks for missed alerts when the app launches
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

    /// Saves a triggered alert in UserDefaults
    private func saveTriggeredAlert(for time: String) {
        var triggeredAlerts = UserDefaults.standard.array(forKey: "TriggeredAlerts") as? [String] ?? []
        triggeredAlerts.append(time)
        UserDefaults.standard.set(triggeredAlerts, forKey: "TriggeredAlerts")
    }

    /// Checks if an alert has already been triggered
    private func hasAlertBeenTriggered(for time: String) -> Bool {
        let triggeredAlerts = UserDefaults.standard.array(forKey: "TriggeredAlerts") as? [String] ?? []
        return triggeredAlerts.contains(time)
    }
    
    /// Resets triggered alerts when a new day starts
    private func resetAlertsForNewDay() {
        let now = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        let todayString = "\(now.year!)-\(now.month!)-\(now.day!)"

        let lastReset = UserDefaults.standard.string(forKey: "LastResetDate") ?? ""

        if lastReset != todayString {
            UserDefaults.standard.set([], forKey: "TriggeredAlerts") // Clear previous alerts
            UserDefaults.standard.set(todayString, forKey: "LastResetDate") // Store today's date
        }
    }
    
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
