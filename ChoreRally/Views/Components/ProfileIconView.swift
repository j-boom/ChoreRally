//
//  ProfileIconView.swift
//  ChoreRallyApp
//
//  Created by Gemini on [Date].
//
//  This is a reusable view component that displays a user's profile
//  icon and name.
//

import SwiftUI

struct ProfileIconView: View {
    let profile: UserProfile
    
    var body: some View {
        VStack {
            Image(systemName: profile.avatarSymbolName)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(profile.isParent ? .blue : .green)
                .padding()
                .background(Color(.systemGray6))
                .clipShape(Circle())
            
            Text(profile.name)
                .font(.headline)
        }
    }
}

// MARK: - Preview

// The preview needs a sample UserProfile to work.
struct ProfileIconView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileIconView(profile: UserProfile(name: "Alex", avatarSymbolName: "face.smiling.fill", isParent: false))
    }
}
