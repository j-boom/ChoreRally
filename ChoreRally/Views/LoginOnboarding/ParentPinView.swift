//
//  ParentPinView.swift
//  ChoreRally
//
//  Created by Jim Bergren on 8/27/25.
//


//
//  ParentPinView.swift
//  ChoreRally
//
//  Created by Gemini on [Date].
//
//  This view provides a keypad for PIN entry.
//

import SwiftUI

struct ParentPinView: View {
    
    let title: String
    // This closure is called when a 4-digit PIN is entered.
    let onPinEntered: (String) -> Void
    
    @State private var pin: String = ""
    
    private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    
    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.title)
            
            // Display dots for the entered PIN digits
            HStack(spacing: 20) {
                ForEach(0..<4) { index in
                    Circle()
                        .frame(width: 20, height: 20)
                        .foregroundColor(index < pin.count ? .primary : .gray.opacity(0.5))
                }
            }
            .padding()
            
            // Keypad
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(1...9, id: \.self) { number in
                    keypadButton(for: "\(number)")
                }
                
                // Empty space for layout
                Color.clear
                
                keypadButton(for: "0")
                
                Button(action: deleteDigit) {
                    Image(systemName: "delete.left")
                        .font(.title)
                        .frame(maxWidth: .infinity, minHeight: 60)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func keypadButton(for digit: String) -> some View {
        Button(action: { appendDigit(digit) }) {
            Text(digit)
                .font(.title)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, minHeight: 60)
                .background(Color(.systemGray6))
                .clipShape(Circle())
        }
    }
    
    private func appendDigit(_ digit: String) {
        guard pin.count < 4 else { return }
        pin.append(digit)
        
        if pin.count == 4 {
            onPinEntered(pin)
            // Reset pin after a short delay for user feedback
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                pin = ""
            }
        }
    }
    
    private func deleteDigit() {
        if !pin.isEmpty {
            pin.removeLast()
        }
    }
}
