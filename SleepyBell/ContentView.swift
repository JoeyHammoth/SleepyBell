//
//  ContentView.swift
//  SleepyBell
//
//  Created by James Nikolas on 1/31/25.
//

import SwiftUI

struct ContentView: View {
    @State private var showForm = false
    @State private var selectedDayNight: String = "AM"
    
    
    var body: some View {
        ZStack {
            DayNightToggleView(isNight: selectedDayNight == "AM" ? false : true)
            
            VStack {
                Spacer()
                Button(action: {
                    withAnimation {
                        showForm.toggle()
                    }
                }) {
                    Text("Show Form")
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .foregroundColor(.black)
                        .clipShape(Capsule())
                        .shadow(radius: 5)
                }
                .padding()
                
            }
            
            if showForm {
                DraggableTransparentForm(dayNight: $selectedDayNight, showForm: $showForm)
            }
        }
    }
}

#Preview {
    ContentView()
}
