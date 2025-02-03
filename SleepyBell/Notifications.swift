//
//  Notifications.swift
//  SleepyBell
//
//  Created by James Nikolas on 2/4/25.
//

import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import UserNotifications

func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if granted {
            print("Permission granted")
        } else {
            print("Permission denied")
        }
    }
}


func scheduleNotification(alarms: AlarmList, index: Int) {
    let content = UNMutableNotificationContent()
    content.title = "Alarm"
    content.body = "Time to wake up!"
    content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "sound.wav"))

    // Set the desired time (e.g., 8:00 AM)
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

    let request = UNNotificationRequest(identifier: "alarmNotification", content: content, trigger: trigger)

    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("Error scheduling notification: \(error.localizedDescription)")
        } else {
            print("Notification scheduled")
        }
    }
}



struct Notifications: View {
    
    @Binding var starAmount: Int
    @Binding var showForm: Bool
    @Binding var mode: String
    
    @State private var offsetY: CGFloat = 400  // Start hidden below screen
    @State private var lastOffset: CGFloat = 400 // Store last position to prevent jumps
    @State private var dragOffset: CGFloat = 0 // Track user movement
    
    private var notificationList: [String] {
        var notiList: [String] = []
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            for request in requests {
                notiList.append("\(request.identifier)")
            }
        }
        return notiList
    }

    var body: some View {
        VStack {
            Capsule()
                .frame(width: 50, height: 5)
                .foregroundColor(.gray.opacity(0.8))
                .padding(5)
            NavigationStack {
                Form {
                    ForEach(notificationList, id: \.self) { noti in
                        Section {
                            VStack {
                                Text(noti) // TODO: replace the id with notification datetime component
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundStyle(Color.white)
                                    .padding()
                                
                                Button(action: {
                                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [noti])
                                }) {
                                    Image(systemName: "trash.fill") // Use a system image for the alarm icon
                                        .resizable()
                                        .frame(width: 30, height: 24) // Set the size of the icon
                                        .foregroundColor(.black) // Set the icon color
                                        .padding()
                                        .background(Color.white.opacity(0.8))
                                        .clipShape(Capsule())
                                        .shadow(radius: 5)
                                }
                                .padding()
                            }
                        }
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
