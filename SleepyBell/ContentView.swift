//
//  ContentView.swift
//  SleepyBell
//
//  Created by James Nikolas on 1/31/25.
//

import SwiftUI


struct DayNightToggleView: View {
    var isNight: Bool

    var body: some View {
        ZStack {
            DaylightBackgroundView()
                .opacity(isNight ? 0 : 1)  // Fade out daytime when switching to night
            
            StarryBackgroundView()
                .opacity(isNight ? 1 : 0)  // Fade in stars when switching to night
        }
        .animation(.easeInOut(duration: 2.0), value: isNight)  // Smooth transition
    }
}

struct DaylightBackgroundView: View {
    @State private var sunPosition: CGFloat = -100
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.white]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
        }
    }
}

struct StarryBackgroundView: View {
    @State private var stars: [Star] = []
    
    let starCount = 100
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                
                ForEach(stars) { star in
                    Circle()
                        .frame(width: star.size, height: star.size)
                        .foregroundColor(.white)
                        .opacity(star.opacity)
                        .position(x: star.x, y: star.y)
                }
            }
            .onAppear {
                generateStars(in: geometry.size)
                animateStars()
            }
        }
    }

    private func generateStars(in size: CGSize) {
        stars = (0..<starCount).map { _ in
            Star(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height),
                size: CGFloat.random(in: 1...3),
                opacity: Double.random(in: 0.3...1.0)
            )
        }
    }

    private func animateStars() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                stars.indices.forEach { index in
                    stars[index].opacity = Double.random(in: 0.3...1.0)
                }
            }
        }
    }
}

struct Star: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var opacity: Double
}

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

struct DraggableTransparentForm: View {
    let dayNightList = ["AM", "PM"]
    @Binding var dayNight: String
    @Binding var showForm: Bool
    @State private var offsetY: CGFloat = 400  // Start hidden below screen
    @State private var lastOffset: CGFloat = 400 // Store last position to prevent jumps
    @State private var dragOffset: CGFloat = 0 // Track user movement

    var body: some View {
        VStack {
            Capsule()
                .frame(width: 50, height: 5)
                .foregroundColor(.gray.opacity(0.8))
                .padding(5)

            Form {
                Section(header: Text("User Info")) {
                    TextField("Name", text: .constant(""))
                    TextField("Email", text: .constant(""))
                }
                Section {
                    Picker("Day/Night", selection: $dayNight) {
                        ForEach(dayNightList, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                Section {
                    Button("Submit") {
                        print("Form Submitted")
                    }
                }
            }
            .scrollContentBackground(.hidden) // Hide form background
        }
        .frame(height: 500)
        .background(.ultraThinMaterial) // Transparent blur effect
        .cornerRadius(20)
        .offset(y: offsetY + dragOffset)  // Combine base offset with drag movement
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    dragOffset = gesture.translation.height // Move dynamically
                }
                .onEnded { _ in
                    let newOffset = lastOffset + dragOffset
                    
                    if newOffset > 250 {  // Close form if dragged down far
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            offsetY = 400
                            showForm = false
                        }
                        lastOffset = 400
                    } else {  // Snap back up if not dragged far enough
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            offsetY = 100
                        }
                        lastOffset = 100
                    }
                    
                    dragOffset = 0  // Reset the drag movement
                }
        )
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                offsetY = 100
                lastOffset = 100
            }
        }
    }
}

#Preview {
    ContentView()
}
