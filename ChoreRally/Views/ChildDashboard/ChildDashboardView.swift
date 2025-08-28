//
//  ChildDashboardView.swift
//  ChoreRally
//
//  Created by Gemini on [Date].
//
//  This is the main TabView for a logged-in child.
//

import SwiftUI

struct ChildDashboardView: View {
    
    let childProfile: UserProfile
    let familyID: String
    
    var body: some View {
        TabView {
            // --- Tab 1: Home ---
            ChildHomeView(childProfile: childProfile, familyID: familyID)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            // --- Tab 2: My Chores ---
            Text("My Chores (Coming Soon)")
                .tabItem {
                    Label("My Chores", systemImage: "checkmark.circle.fill")
                }
            
            // --- Tab 3: Extra Chores ---
            Text("Extra Chores (Coming Soon)")
                .tabItem {
                    Label("Extra Chores", systemImage: "star.fill")
                }
        }
    }
}
