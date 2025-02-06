//
//  Settings.swift
//  SleepyBell
//
//  Created by JoeyHammoth on 2/2/25.
//

import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect

struct Settings: View {
    
    let modeList = ["Light", "Dark"]
    
    @Binding var starAmount: Int
    @Binding var showForm: Bool
    @Binding var mode: String
    
    @State private var offsetY: CGFloat = 400  // Start hidden below screen
    @State private var lastOffset: CGFloat = 400 // Store last position to prevent jumps
    @State private var dragOffset: CGFloat = 0 // Track user movement
    

    var body: some View {
        VStack {
            Capsule()
                .frame(width: 50, height: 5)
                .foregroundColor(.gray.opacity(0.8))
                .padding(5)
            NavigationStack {
                Form {
                    Section {
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
                            .foregroundStyle(mode == "Dark" ? Color.gray : Color.white)
                    }
                    
                    Section {
                        Picker("Day/Night", selection: $mode) {
                            ForEach(modeList, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(.segmented)
                    } header: {
                        Text("Set background")
                            .foregroundStyle(mode == "Dark" ? Color.gray : Color.white)
                    }
                    
                }
                .navigationTitle("Settings")
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

