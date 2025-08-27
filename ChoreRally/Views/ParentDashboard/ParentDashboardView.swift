//
//  ParentDashboardView.swift
//  ChoreRallyApp
//
//  Created by Gemini on [Date].
//
//  This is the main view for a logged-in parent. It uses a TabView
//  to organize the different management sections of the app.
//

import SwiftUI

struct ParentDashboardView: View {
    
    // MARK: - Properties
    
    // The dashboard needs the familyID to pass to its child views.
    let familyID: String
    
    // MARK: - Body
    
    var body: some View {
        TabView {
            // --- Tab 1: Home ---
            Text("Home View")
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            // --- Tab 2: Assignments (New) ---
            ChoreAssignmentView(familyID: familyID)
                .tabItem {
                    Label("Assignments", systemImage: "calendar.badge.plus")
                }
            
            // --- Tab 3: Chores ---
            ChoresManagementView(familyID: familyID)
                .tabItem {
                    Label("Chores", systemImage: "checkmark.circle.fill")
                }
            
            // --- Tab 4: Family ---
            FamilyManagementView(familyID: familyID)
                .tabItem {
                    Label("Family", systemImage: "person.3.fill")
                }
            
            // --- Tab 5: Ledger ---
            Text("Ledger View")
                .tabItem {
                    Label("Ledger", systemImage: "scroll.fill")
                }
        }
    }
}

// MARK: - Preview

struct ParentDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        // We provide a dummy familyID for the preview to work.
        ParentDashboardView(familyID: "previewFamilyID")
    }
}
