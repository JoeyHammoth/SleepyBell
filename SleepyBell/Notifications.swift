//
//  Notifications.swift
//  SleepyBell
//
//  Created by JoeyHammoth on 2/4/25.
//

import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import UserNotifications

// MARK: - Notification Permission & Scheduling

/// Requests permission from the user to display notifications (alerts, sounds, and badges).
///
/// This function uses `UNUserNotificationCenter` to request authorization for notifications. After the request,
/// it prints whether permission was granted and then retrieves and prints the updated notification settings.
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

/// Schedules a local notification using the specified alarm parameters.
///
/// The notification includes a title, body, and custom sound. The function updates the provided sound list
/// to associate the notification identifier with the sound file. The trigger is configured using date components
/// from the alarm.
///
/// - Parameters:
///   - id: A unique identifier for the notification.
///   - alarms: An `AlarmList` instance containing alarm details.
///   - index: The index of the alarm within the `alarms` arrays.
///   - filename: The name of the sound file (with extension) to play when the notification triggers.
///   - soundList: An inout dictionary mapping notification identifiers to sound filenames.
func scheduleNotification(id: String, alarms: AlarmList, index: Int, filename: String, soundList: inout [String:String]) {
    let content = UNMutableNotificationContent()
    content.title = "Alarm"
    content.body = "Time to wake up!"
    content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: filename))
    soundList[id] = filename
    
    var dateComponents = DateComponents()
    
    // Compute the actual hour, handling the 24-hour edge-case
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

// MARK: - Notifications View

/// A view that displays a list of pending notification alarms and allows for modification.
///
/// The `Notifications` view shows a list of scheduled notifications, including their associated sound and trigger count.
/// Users can delete individual notifications. The view is presented as a draggable form with a transparent blur background.
struct Notifications: View {
    
    // MARK: - Bindings
    
    /// A binding indicating whether the form is visible.
    @Binding var showForm: Bool
    
    /// A binding for the current app mode (e.g., "Light" or "Dark").
    @Binding var mode: String
    
    /// A binding to a dictionary mapping notification identifiers to their associated sound filenames.
    @Binding var soundDict: [String:String]
    
    /// A binding to a dictionary mapping notification identifiers to the number of times they have been triggered.
    @Binding var occurencesDict: [String:Int]
    
    // MARK: - State Properties
    
    /// The base vertical offset for the view (starts off-screen).
    @State private var offsetY: CGFloat = 400
    
    /// Stores the last offset value to prevent abrupt jumps during dragging.
    @State private var lastOffset: CGFloat = 400
    
    /// The dynamic drag offset applied during a user drag gesture.
    @State private var dragOffset: CGFloat = 0
    
    /// A list of pending notification identifiers.
    @State private var notificationList: [String] = []
    
    /// The gradient colors used for the background of each list row.
    @State private var gradColors: [Color] = [Color.gray.opacity(0.5), Color.black]
    
    // MARK: - Notification Fetching & Animation Methods
    
    /// Fetches pending notification requests and updates the `notificationList`.
    ///
    /// This function retrieves all pending notifications using `UNUserNotificationCenter` and extracts their identifiers.
    func fetchNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                self.notificationList = requests.map { $0.identifier }
            }
        }
    }
    
    /// Animates the background gradient for notification list rows.
    ///
    /// A timer is scheduled to update `gradColors` every 5 seconds with an ease-in-out animation,
    /// simulating a subtle change in appearance.
    func animateGradient() {
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 3)) {
                if gradColors == [Color.gray.opacity(0.5), Color.black] {
                    gradColors = [Color.gray, Color.black] // Simulating noon
                } else {
                    gradColors = [Color.gray.opacity(0.5), Color.black] // Reset to original state
                }
            }
        }
    }
    
    // MARK: - View Body
    
    var body: some View {
        VStack {
            // A draggable capsule indicator at the top of the form.
            Capsule()
                .frame(width: 50, height: 5)
                .foregroundColor(.gray.opacity(0.8))
                .padding(5)
            
            // The main content is wrapped in a NavigationStack with a Form.
            NavigationStack {
                Form {
                    // About Section
                    Section {
                        Text("Here is a list of all scheduled notification alarms. Modify them at your own discretion.")
                    } header: {
                        Text("About")
                            .foregroundStyle(Color.white)
                            .fontWeight(.bold)
                    }
                    
                    // Notification List Section
                    ForEach(notificationList, id: \.self) { noti in
                        Section {
                            VStack {
                                // Display the notification identifier.
                                Text(noti)
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundStyle(Color.white)
                                
                                // Display the associated sound title.
                                Text("Sound: \(soundDict[noti, default: "Unknown"])")
                                    .font(.system(size: 25, weight: .light))
                                    .foregroundStyle(Color.white)
                                
                                // Buttons for modifying the notification.
                                HStack {
                                    // Delete button to remove the notification.
                                    Button(action: {
                                        withAnimation(.easeOut(duration: 0.5)) {
                                            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [noti])
                                            fetchNotifications()
                                        }
                                    }) {
                                        Image(systemName: "trash.fill")
                                            .resizable()
                                            .frame(width: 24, height: 24)
                                            .foregroundColor(.black)
                                            .padding()
                                            .background(Color.white.opacity(0.8))
                                            .clipShape(Capsule())
                                            .shadow(radius: 5)
                                    }
                                    Spacer()
                                    // Display the number of triggers (occurrences) for the notification.
                                    if let count = occurencesDict[noti] {
                                        Text("Triggers: \(count)")
                                    } else {
                                        Text("Triggers: 0")
                                    }
                                }
                                .padding([.leading, .trailing])
                            }
                        } header: {
                            Text("Notification \(noti)")
                                .foregroundStyle(Color.white)
                                .fontWeight(.bold)
                        }
                        // Apply a transition effect when the section appears.
                        .transition(.move(edge: .top).combined(with: .opacity))
                        // Set a gradient background for the list row.
                        .listRowBackground(
                            LinearGradient(gradient: Gradient(colors: gradColors),
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
                // Hide the default form background.
                .scrollContentBackground(.hidden)
            }
            // Use SwiftUIIntrospect to customize the navigation stack background.
            .introspect(.navigationStack, on: .iOS(.v16...)) {
                $0.viewControllers.forEach { controller in
                    controller.view.backgroundColor = .clear
                }
            }
        }
        // Make the view occupy the full screen.
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // Apply a transparent blur effect as the background.
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
        // Combine the base offset with the current drag offset.
        .offset(y: offsetY + dragOffset)
        // Add a drag gesture to allow the user to dismiss the form.
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    // Update the drag offset as the user drags.
                    dragOffset = gesture.translation.height
                }
                .onEnded { _ in
                    let newOffset = offsetY + dragOffset
                    
                    if newOffset > 250 {  // If dragged down sufficiently, dismiss the form.
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            offsetY = UIScreen.main.bounds.height
                            showForm = false
                        }
                    } else {  // Otherwise, snap back to the original position.
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            offsetY = 0
                        }
                    }
                    
                    // Reset the drag offset.
                    dragOffset = 0
                }
        )
        .onAppear {
            // Animate the view into position when it appears.
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                offsetY = 0
                lastOffset = 0
            }
            // Fetch pending notifications.
            fetchNotifications()
        }
        .onChange(of: showForm) {
            if showForm {
                // Reset offset when the form is shown.
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    offsetY = 0
                    lastOffset = 0
                }
            } else {
                // Move off-screen when the form is dismissed.
                offsetY = UIScreen.main.bounds.height
            }
        }
    }
}
