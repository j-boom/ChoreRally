//
//  UserSelectionView.swift
//  ChoreRallyApp
//
//  Created by Gemini on [Date].
//
//  This view displays a grid of user profiles for selection,
//  similar to a Netflix or Disney+ user selection screen.
//

import SwiftUI

struct UserSelectionView: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel = UserSelectionViewModel()
    
    let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 120))
    ]
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if !viewModel.shouldShowOnboarding {
                Text("Who's using ChoreRally?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 50)
                    .padding(.bottom, 30)
                
                ScrollView {
                    VStack(alignment: .center, spacing: 30) {
                        // --- Parents Section ---
                        if !viewModel.parentProfiles.isEmpty {
                            VStack(alignment: .leading) {
                                Text("Parents")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                
                                LazyVGrid(columns: columns, spacing: 20) {
                                    ForEach(viewModel.parentProfiles, id: \.name) { profile in
                                        ProfileIconView(profile: profile)
                                            .onTapGesture {
                                                viewModel.profileTapped(profile: profile)
                                            }
                                    }
                                }
                            }
                        }
                        
                        // --- Children Section ---
                        if !viewModel.childProfiles.isEmpty {
                            VStack(alignment: .leading) {
                                Text("Children")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                
                                LazyVGrid(columns: columns, spacing: 20) {
                                    ForEach(viewModel.childProfiles, id: \.name) { profile in
                                        ProfileIconView(profile: profile)
                                            .onTapGesture {
                                                viewModel.profileTapped(profile: profile)
                                            }
                                    }
                                }
                            }
                        }
                        
                        // --- The "Add User" button has been removed from this view ---
                        
                    }
                    .padding(.horizontal)
                }
                
            } else {
                Spacer()
            }
        }
        .sheet(isPresented: $viewModel.shouldShowOnboarding) {
            ParentOnboardingView()
        }
        // --- The sheet modifier for adding a user has been removed ---
        /*
        .sheet(isPresented: $viewModel.shouldShowAddUserSheet) {
            if let familyID = viewModel.familyID {
                AddUserProfileView(familyID: familyID)
            }
        }
        */
    }
}

// MARK: - Preview

struct UserSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        UserSelectionView()
    }
}
