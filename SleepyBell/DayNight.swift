//
//  DayNight.swift
//  SleepyBell
//
//  Created by JoeyHammoth on 1/31/25.
//

import SwiftUI

/// A view that toggles between a daylight background and a starry night background.
///
/// Depending on the value of `isNight`, this view fades between a daylight view and a starry
/// view. It binds to an external `stars` count, which is used by the starry background.
struct DayNightToggleView: View {
    /// A Boolean value that determines whether it is night.
    var isNight: Bool
    
    /// A binding to the number of stars displayed in the starry background.
    @Binding var stars: Int

    var body: some View {
        ZStack {
            // Display the daylight background when it is not night.
            DaylightBackgroundView()
                .opacity(isNight ? 0 : 1)  // Fade out the daylight background when switching to night.
            
            // Display the starry background when it is night.
            StarryBackgroundView(starCount: $stars)
                .opacity(isNight ? 1 : 0)  // Fade in the stars when switching to night.
        }
        // Animate the transition between day and night using an ease-in-out animation.
        .animation(.easeInOut(duration: 2.0), value: isNight)
    }
}

/// A view that displays a daylight background using a linear gradient.
///
/// The gradient simulates the changes in daylight by periodically animating its colors,
/// giving the impression of a dynamic sky during the day.
struct DaylightBackgroundView: View {
    /// The current position of the sun (not currently used in the view but reserved for future enhancements).
    @State private var sunPosition: CGFloat = -100
    /// The array of colors used to generate the linear gradient.
    ///
    /// Initially set to a gradient from blue (morning) to white, it animates to simulate noon.
    @State private var gradientColors: [Color] = [Color.blue, Color.white]

    var body: some View {
        ZStack {
            // A linear gradient that covers the entire screen.
            LinearGradient(
                gradient: Gradient(colors: gradientColors),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            // Animate changes to the gradient colors smoothly.
            .animation(.easeInOut(duration: 3), value: gradientColors)
        }
        // Start the gradient animation when the view appears.
        .onAppear {
            animateGradient()
        }
    }

    /// Animates the gradient by toggling its color array periodically.
    ///
    /// A timer is scheduled to fire every 5 seconds, and on each tick, the gradient colors are updated
    /// using a smooth ease-in-out animation. This simulates a transition from morning to noon and back.
    func animateGradient() {
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 3)) {
                if gradientColors == [Color.blue, Color.white] {
                    // Change to a gradient that simulates noon.
                    gradientColors = [Color.yellow, Color.blue, Color.white]
                } else {
                    // Reset to the morning gradient.
                    gradientColors = [Color.blue, Color.white]
                }
            }
        }
    }
}

/// A view that displays a starry background.
///
/// This view generates and animates a collection of stars based on a bound star count. The stars are
/// randomly generated in size, opacity, and position, and they animate to create a flickering effect.
struct StarryBackgroundView: View {
    /// The internal array of stars to display.
    @State private var stars: [Star] = []
    
    /// A binding to the number of stars to generate.
    @Binding var starCount: Int
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Set a solid black background that covers the entire screen.
                Color.black.ignoresSafeArea()
                
                // Draw each star as a white circle with varying size and opacity.
                ForEach(stars) { star in
                    Circle()
                        .frame(width: star.size, height: star.size)
                        .foregroundColor(.white)
                        .opacity(star.opacity)
                        .position(x: star.x, y: star.y)
                }
            }
            // When the view appears, generate and animate the stars.
            .onAppear {
                generateStars(in: geometry.size)
                animateStars()
            }
            // Regenerate stars if the star count changes.
            .onChange(of: starCount) {
                generateStars(in: geometry.size)
            }
        }
    }

    /// Generates an array of stars based on the current `starCount`.
    ///
    /// Each star is created with a random position within the provided size, a random size between 1 and 3,
    /// and a random opacity between 0.3 and 1.0.
    ///
    /// - Parameter size: The size of the available space in which to generate stars.
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

    /// Animates the stars by updating their opacity to simulate a twinkling effect.
    ///
    /// A timer is scheduled to fire every 0.5 seconds. On each tick, the opacity of each star is updated
    /// using a smooth ease-in-out animation, creating a subtle flicker.
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

/// A model representing a single star in the starry background.
///
/// Each star has a unique identifier, a position (`x` and `y` coordinates), a size, and an opacity.
/// This model conforms to `Identifiable` to be used in SwiftUI's `ForEach` view.
struct Star: Identifiable {
    /// A unique identifier for the star.
    let id = UUID()
    /// The x-coordinate position of the star.
    var x: CGFloat
    /// The y-coordinate position of the star.
    var y: CGFloat
    /// The diameter of the star.
    var size: CGFloat
    /// The opacity of the star.
    var opacity: Double
}
