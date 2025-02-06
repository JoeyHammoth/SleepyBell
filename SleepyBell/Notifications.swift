//
//  Notifications.swift
//  SleepyBell
//
//  Created by JoeyHammoth on 2/4/25.
//

import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import UserNotifications

func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        DispatchQueue.main.async {
            if let error = error {
                print("Error requesting permission: \(error.localizedDescription)")
            } else {
                print("Permission granted: \(granted)")
                // Re-check permission after requesting
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    DispatchQueue.main.async {
                        print("New permission status: \(settings.authorizationStatus.rawValue)")
                    }
                }
            }
        }
    }
}


func scheduleNotification(id: String, alarms: AlarmList, index: Int, filename: String, soundList: inout [String:String]) { // inout to be able to modify soundlist
    let content = UNMutableNotificationContent()
    content.title = "Alarm"
    content.body = "Time to wake up!"
    content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: filename))
    soundList[id] = filename
    

    var dateComponents = DateComponents()
    
    var realHour: Int {
        if alarms.realHourList[index] == 24 {
            return 0
        } else {
            return alarms.realHourList[index]
        }
    }
    
    dateComponents.hour = realHour
    dateComponents.minute = alarms.minList[index]
    dateComponents.second = alarms.secList[index]

    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

    let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("Error scheduling notification: \(error.localizedDescription)")
        } else {
            print("Notification scheduled")
        }
    }
}



struct Notifications: View {
    
    @Binding var showForm: Bool
    @Binding var mode: String
    @Binding var soundDict: [String:String]
    @Binding var occurencesDict: [String:Int]
    
    @State private var offsetY: CGFloat = 400  // Start hidden below screen
    @State private var lastOffset: CGFloat = 400 // Store last position to prevent jumps
    @State private var dragOffset: CGFloat = 0 // Track user movement
    
    @State private var notificationList: [String] = []
    
    @State private var gradColors: [Color] = [Color.red, Color.white]
    
    func fetchNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                self.notificationList = requests.map { $0.identifier }
            }
        }
    }
    
    func animateGradient() {
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 3)) {
                if gradColors == [Color.red, Color.white] {
                    gradColors = [Color.pink, Color.white] // Simulating noon
                } else {
                    gradColors = [Color.red, Color.white] // Reset to morning
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
                        Text("Here is a list of all sheduled notification alarms. Modify them at your own discretion.")
                    } header: {
                        Text("About")
                            .foregroundStyle(mode == "Dark" ? Color.gray : Color.white)
                    }
                    ForEach(notificationList, id: \.self) { noti in
                        Section {
                            VStack {
                                Text(noti) 
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundStyle(Color.white)
                                
                                Text("Sound: \(soundDict[noti, default: "Unkown"])")
                                    .font(.system(size: 25, weight: .light))
                                    .foregroundStyle(Color.white)
                                
                                HStack {
                                    Button(action: {
                                        withAnimation(.easeOut(duration: 0.5)) {
                                            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [noti])
                                            fetchNotifications()
                                        }
                                    }) {
                                        Image(systemName: "trash.fill") // Use a system image for the alarm icon
                                            .resizable()
                                            .frame(width: 24, height: 24) // Set the size of the icon
                                            .foregroundColor(.black) // Set the icon color
                                            .padding()
                                            .background(Color.white.opacity(0.8))
                                            .clipShape(Capsule())
                                            .shadow(radius: 5)
                                    }
                                    Spacer()
                                    if occurencesDict[noti] != nil {
                                        Text("Triggers: \(occurencesDict[noti]!)")
                                    } else {
                                        Text("Triggers: 0")
                                    }
                                }
                                .padding([.leading, .trailing])
                            }
                        } header: {
                            Text("Notification \(noti)")
                                .foregroundStyle(mode == "Dark" ? Color.gray : Color.white)
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .listRowBackground(LinearGradient(gradient: Gradient(colors: gradColors),
                                                          startPoint: .top,
                                                          endPoint: .bottom)
                                            .animation(.easeInOut(duration: 3), value: gradColors)
                        )
                    }
                    .onAppear {
                        animateGradient()
                    }
                }
                .navigationTitle("Notifications")
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
            fetchNotifications()
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
