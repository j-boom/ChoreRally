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

            // --- Tab 2: Extra Chores ---
            ExtraChoresView(childProfile: childProfile, familyID: familyID)
                .tabItem {
                    Label("Extra Chores", systemImage: "star.fill")
                }
            
            // --- Tab 3: Ledger ---
            ChildLedgerView(childProfile: childProfile, familyID: familyID)
                .tabItem {
                    Label("Ledger", systemImage: "wallet.bifold")
                }
        }
    }
}
