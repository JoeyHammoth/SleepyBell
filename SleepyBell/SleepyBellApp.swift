//
//  SleepyBellApp.swift
//  SleepyBell
//
//  Created by James Nikolas on 1/31/25.
//

import SwiftUI

@main
struct SleepyBellApp: App {
    let persistentContainer = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistentContainer.container.viewContext)
        }
    }
}
