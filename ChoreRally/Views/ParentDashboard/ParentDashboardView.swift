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
            // This will be the main screen with pending approvals and balances.
            Text("Home View")
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            // --- Tab 2: Chores ---
            ChoresManagementView(familyID: familyID)
                .tabItem {
                    Label("Chores", systemImage: "checkmark.circle.fill")
                }
            
            // --- Tab 3: Family ---
            // This is where parents will manage profiles and invite others.
            FamilyManagementView(familyID: familyID)
                .tabItem {
                    Label("Family", systemImage: "person.3.fill")
                }
            
            // --- Tab 4: Ledger ---
            // This will show the transaction history and allow for payments.
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
