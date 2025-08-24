//
//  FamilyManagementView.swift
//  ChoreRallyApp
//
//  Created by Gemini on [Date].
//
//  This view is the main screen for the "Family" tab, allowing parents
//  to manage user profiles.
//

import SwiftUI

struct FamilyManagementView: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel: FamilyManagementViewModel
    private let familyID: String
    
    init(familyID: String) {
        self.familyID = familyID
        _viewModel = StateObject(wrappedValue: FamilyManagementViewModel(familyID: familyID))
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            List {
                // --- Guardians Section ---
                Section(header: Text("Guardians")) {
                    ForEach(viewModel.parentProfiles) { profile in
                        Text(profile.name)
                    }
                }
                
                // --- Children Section ---
                Section(header: Text("Children")) {
                    ForEach(viewModel.childProfiles) { profile in
                        // Tapping a child will eventually go to an edit/assign screen
                        Text(profile.name)
                    }
                }
            }
            .navigationTitle("Manage Family")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.shouldShowAddUserSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.shouldShowAddUserSheet) {
                AddUserProfileView(familyID: familyID)
            }
        }
    }
}
