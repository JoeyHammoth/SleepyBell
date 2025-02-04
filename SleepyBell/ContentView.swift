//
//  ContentView.swift
//  SleepyBell
//
//  Created by James Nikolas jon 1/31/25.
//

import SwiftUI

struct ContentView: View {
    @State private var starNum: Int = 100
    @State private var showNotifications = false
    @State private var showSettings = false
    @State private var showForm = false
    @State private var selectedDayNight: String = "AM"
    @State private var currentTime: String = ""
    @State private var darkMode: String = "Dark"
    @State private var alert: Bool = false
    @State private var alarmArr: AlarmList = fetchLatestAlarm()
    
    
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
                    .padding()
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
                    .padding()
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
                    .padding()
                }
                
            }
            .alert(isPresented: $alert) {
                Alert(title: Text("Improper Secondary Alarm!"),
                      message: Text("Please choose a secondary alarm time that is between 1 and 10 minutes more than your last alarm."),
                      dismissButton: .default(Text("OK")))
            }
            .onAppear() {
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
                DraggableTransparentForm(mode: $darkMode, showForm: $showForm, alertBool: $alert, alarms: $alarmArr)
            }
            
            if showSettings {
                Settings(starAmount: $starNum, showForm: $showSettings, mode: $darkMode)
            }
            
            if showNotifications {
                Notifications(showForm: $showNotifications, mode: $darkMode)
            }
        }
        .onAppear() {
            requestNotificationPermission()
        }
    }
    
    func startTimer() {
        // Update the current time every second
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            updateCurrentTime()
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
