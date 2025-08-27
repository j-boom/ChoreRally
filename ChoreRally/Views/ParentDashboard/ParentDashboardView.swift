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
    
    let familyID: String
    
    // MARK: - Body
    
    var body: some View {
        TabView {
            // --- Tab 1: Home ---
            ParentHomeView(familyID: familyID)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            // --- Tab 2: Assignments ---
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
            LedgerView(familyID: familyID)
                .tabItem {
                    Label("Ledger", systemImage: "scroll.fill")
                }
        }
    }
}

// MARK: - Preview

struct ParentDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        ParentDashboardView(familyID: "previewFamilyID")
    }
}
