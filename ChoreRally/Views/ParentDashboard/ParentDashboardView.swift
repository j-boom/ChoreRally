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
    
    @State private var selectedTab: Int = 0
    @State private var homeViewID = UUID()
    
    // MARK: - Body
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // --- Tab 1: Home ---
            ParentHomeView(familyID: familyID)
                .id(homeViewID) // This ID forces the view to be recreated when it changes.
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            // --- Tab 2: Assignments ---
            ChoreAssignmentView(familyID: familyID)
                .tabItem {
                    Label("Assignments", systemImage: "calendar.badge.plus")
                }
                .tag(1)
            
            // --- Tab 3: Chores ---
            ChoresManagementView(familyID: familyID)
                .tabItem {
                    Label("Chores", systemImage: "checkmark.circle.fill")
                }
                .tag(2)
            
            // --- Tab 4: Family ---
            FamilyManagementView(familyID: familyID)
                .tabItem {
                    Label("Family", systemImage: "person.3.fill")
                }
                .tag(3)
            
            // --- Tab 5: Ledger ---
            LedgerView(familyID: familyID)
                .tabItem {
                    Label("Ledger", systemImage: "scroll.fill")
                }
                .tag(4)
        }
        .onChange(of: selectedTab) {
            // When the user selects the Home tab, change the ID to force a refresh.
            if selectedTab == 0 {
                homeViewID = UUID()
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
