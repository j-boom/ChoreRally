//
//  ChoreRowView.swift
//  ChoreRallyApp
//
//  Created by Gemini on [Date].
//
//  This is a reusable view component that displays the details for a single chore.
//

import SwiftUI

struct ChoreRowView: View {
    let chore: Chore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(chore.name)
                .font(.headline)
            
            Text(chore.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Text("Category: \(chore.category.rawValue)")
                Spacer()
                Text("Time: \(chore.estimatedTimeInMinutes) min")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.top, 4)
        }
    }
}

// MARK: - Preview

struct ChoreRowView_Previews: PreviewProvider {
    static var previews: some View {
        ChoreRowView(chore: Chore(name: "Test Chore", description: "This is a test chore.", estimatedTimeInMinutes: 15, difficultyMultiplier: 1.0, category: .cleaning))
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
