//
//  DayNight.swift
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
