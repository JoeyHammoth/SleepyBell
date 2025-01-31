//
//  Form.swift
//  SleepyBell
//
//  Created by James Nikolas on 1/31/25.
//

import SwiftUI

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
