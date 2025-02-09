//
//  Settings.swift
//  SleepyBell
//
//  Created by JoeyHammoth on 2/2/25.
//

import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect

/// A view that presents the settings panel for the SleepyBell application.
///
/// The settings view allows users to adjust aesthetic settings such as:
/// - The number of stars in the night background.
/// - The background mode (light or dark).
/// - Custom font modification (font selection and size).
///
/// The view is presented as a draggable form that slides up from the bottom and supports a transparent blur effect.
struct Settings: View {
    
    // MARK: - Static Data
    
    /// List of background modes.
    let modeList = ["Light", "Dark"]
    
    /// List of available fonts for the custom font modification feature.
    ///
    /// The list is organized by font type:
    /// - System Default
    /// - Serif Fonts
    /// - Sans-Serif Fonts
    /// - Monospace Fonts
    /// - Handwriting & Decorative Fonts
    let fontList = [
        // System Default
        "San Francisco", "Helvetica Neue",
        
        // Serif Fonts
        "Times New Roman", "Georgia", "Palatino", "Baskerville", "Didot",
        
        // Sans-Serif Fonts
        "Arial", "Helvetica", "Verdana", "Gill Sans", "Futura", "Trebuchet MS", "Avenir",
        
        // Monospace Fonts
        "Courier", "Courier New", "Menlo", "Monaco", "SF Mono",
        
        // Handwriting & Decorative Fonts
        "Marker Felt", "Chalkboard SE", "Noteworthy", "Papyrus", "Zapfino"
    ]
    
    // MARK: - Bindings
    
    /// The number of stars to display in the background (used when in night mode).
    @Binding var starAmount: Int
    
    /// A Boolean flag indicating whether the settings form is currently shown.
    @Binding var showForm: Bool
    
    /// The currently selected background mode ("Light" or "Dark").
    @Binding var mode: String
    
    /// The selected font name for the custom font modification.
    @Binding var font: String
    
    /// The selected font size.
    @Binding var size: CGFloat
    
    /// A Boolean flag indicating whether the custom font modification is enabled.
    @Binding var enableChangeFont: Bool
    
    // MARK: - State Properties (Internal)
    
    /// The vertical offset used to position the settings view off-screen initially.
    @State private var offsetY: CGFloat = 400  // Start hidden below the screen.
    
    /// Stores the last offset value to prevent abrupt jumps during dragging.
    @State private var lastOffset: CGFloat = 400
    
    /// The dynamic offset applied during a drag gesture.
    @State private var dragOffset: CGFloat = 0

    // MARK: - View Body
    
    /// The content and layout of the settings view.
    ///
    /// The view consists of a draggable panel that contains a navigation stack with a form.
    /// The form is divided into several sections:
    /// - **About:** A short description of the settings.
    /// - **Star Count:** A slider to adjust the number of stars (for night mode).
    /// - **Background:** A segmented picker to choose between Light and Dark modes.
    /// - **Font Modification:** Toggles and controls for enabling and selecting a custom font and its size.
    var body: some View {
        VStack {
            // A visual indicator (capsule) at the top of the panel for drag handle.
            Capsule()
                .frame(width: 50, height: 5)
                .foregroundColor(.gray.opacity(0.8))
                .padding(5)
            
            // NavigationStack is used to provide a navigation title and styling for the form.
            NavigationStack {
                Form {
                    // MARK: - About Section
                    Section {
                        Text("This is where all settings for the app are located. These settings are for aesthetic purposes only and reset whenever you re-enter the app.")
                    } header: {
                        Text("About")
                            .foregroundStyle(Color.white)
                            .fontWeight(.bold)
                    }
                    
                    // MARK: - Star Count Section
                    Section {
                        // A slider to set the number of stars.
                        Slider(value: Binding(
                            get: {
                                Double(starAmount)
                            },
                            set: { newValue in
                                starAmount = Int(newValue)
                            }),
                               in: 0...1000, step: 1
                        )
                        .padding()
                        
                        Text("Number of stars: \(starAmount)")
                    } header: {
                        Text("Set Star Count (Night Only)")
                            .foregroundStyle(Color.white)
                            .fontWeight(.bold)
                    }
                    
                    // MARK: - Background Mode Section
                    Section {
                        Picker("Day/Night", selection: $mode) {
                            ForEach(modeList, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(.segmented)
                    } header: {
                        Text("Set background")
                            .foregroundStyle(Color.white)
                            .fontWeight(.bold)
                    }
                    
                    // MARK: - Font Modification Section
                    Section {
                        // Toggle to enable or disable font modification.
                        Toggle(isOn: $enableChangeFont) {
                            Text("Enable Font Modification")
                        }
                        
                        // Picker to select a font from the provided list.
                        Picker("Font", selection: $font) {
                            ForEach(fontList, id: \.self) {
                                Text($0)
                            }
                        }
                        
                        // A vertical stack for displaying and modifying the font size.
                        VStack {
                            Text("Font Size: \(size)")
                            Slider(value: Binding(
                                get: {
                                    Double(size)
                                },
                                set: { newValue in
                                    size = CGFloat(newValue)
                                }),
                                   in: 1...40, step: 0.2
                            )
                        }
                    } header: {
                        Text("Font Modification")
                            .foregroundStyle(Color.white)
                            .fontWeight(.bold)
                    }
                }
                .navigationTitle("Settings")
                // Hide the default form background.
                .scrollContentBackground(.hidden)
            }
            // Use SwiftUIIntrospect to adjust the background color of the navigation stack.
            .introspect(.navigationStack, on: .iOS(.v16...)) {
                $0.viewControllers.forEach { controller in
                    controller.view.backgroundColor = .clear
                }
            }
        }
        // Set the frame to occupy the full available space.
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // Apply a transparent blur effect to the background.
        .background(.ultraThinMaterial)
        // Allow the view to extend into safe areas (full screen).
        .ignoresSafeArea()
        // Offset the view vertically based on the drag gesture and initial position.
        .offset(y: offsetY + dragOffset)
        // Attach a drag gesture to allow the settings view to be swiped up or down.
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    // Update the drag offset as the user moves the view.
                    dragOffset = gesture.translation.height
                }
                .onEnded { _ in
                    let newOffset = offsetY + dragOffset
                    
                    // If dragged down beyond a threshold, dismiss the form.
                    if newOffset > 250 {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            offsetY = UIScreen.main.bounds.height
                            showForm = false
                        }
                    } else {
                        // Otherwise, snap the view back to its original position.
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            offsetY = 0
                        }
                    }
                    
                    // Reset the drag offset.
                    dragOffset = 0
                }
        )
        // When the view appears, animate it into view.
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                offsetY = 0
                lastOffset = 0
            }
        }
        // Adjust the view's offset when the showForm binding changes.
        .onChange(of: showForm) {
            if showForm {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    offsetY = 0
                    lastOffset = 0
                }
            } else {
                // If the form is dismissed, move it off-screen.
                offsetY = UIScreen.main.bounds.height
            }
        }
    }
}
