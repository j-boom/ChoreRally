//
//  ChildRowView.swift
//  ChoreRally
//
//  Created by Jim Bergren on 8/24/25.
//


//
//  ChildRowView.swift
//  ChoreRallyApp
//
//  Created by Gemini on [Date].
//
//  This is a reusable view component that displays the details for a single child profile.
//

import SwiftUI

struct ChildRowView: View {
    let childProfile: UserProfile
    
    var body: some View {
        HStack {
            Image(systemName: childProfile.avatarSymbolName)
                .font(.title)
                .foregroundColor(.green)
                .frame(width: 40)
            
            VStack(alignment: .leading) {
                Text(childProfile.name)
                    .font(.headline)
                if let age = childProfile.age {
                    Text("Age: \(age)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

// MARK: - Preview

struct ChildRowView_Previews: PreviewProvider {
    static var previews: some View {
        ChildRowView(childProfile: UserProfile(name: "Alex", avatarSymbolName: "face.smiling.fill", isParent: false, age: 8, rate: 8.0))
            .padding()
            .previewLayout(.sizeThatFits)
    }
}