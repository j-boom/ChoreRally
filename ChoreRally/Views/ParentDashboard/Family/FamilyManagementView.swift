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
                        ChildRowView(childProfile: profile)
                            .onTapGesture {
                                viewModel.selectedChildForEditing = profile
                            }
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
            // This sheet presents the ChildDetailView when a child is selected.
            .sheet(item: $viewModel.selectedChildForEditing) { childProfile in
                // We wrap the detail view in its own NavigationView for the modal context.
                NavigationView {
                    ChildDetailView(childProfile: childProfile, familyID: familyID)
                }
            }
        }
    }
}

// MARK: - Preview

struct FamilyManagementView_Previews: PreviewProvider {
    static var previews: some View {
        FamilyManagementView(familyID: "previewFamilyID")
    }
}
