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
    
    // Create an instance of the ViewModel.
    @StateObject private var viewModel = UserSelectionViewModel()
    
    // Define the grid layout. This creates a flexible grid with
    // enough columns to fit the available space.
    let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 120))
    ]
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            // --- This logic prevents the UI flicker ---
            if viewModel.isLoading {
                // 1. While loading, show a spinner.
                Spacer()
                ProgressView()
                Spacer()
            } else if !viewModel.shouldShowOnboarding {
                // 2. If not loading and not onboarding, show the main view.
                Text("Who's using ChoreRally?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 50)
                    .padding(.bottom, 30)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        // --- Parents Section ---
                        if !viewModel.parentProfiles.isEmpty {
                            Text("Parents")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: columns, spacing: 20) {
                                // --- FIX: Use \.name as the identifier ---
                                ForEach(viewModel.parentProfiles, id: \.name) { profile in
                                    ProfileIconView(profile: profile)
                                        .onTapGesture {
                                            viewModel.profileTapped(profile: profile)
                                        }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // --- Children Section ---
                        if !viewModel.childProfiles.isEmpty {
                            Text("Children")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: columns, spacing: 20) {
                                // --- FIX: Use \.name as the identifier ---
                                ForEach(viewModel.childProfiles, id: \.name) { profile in
                                    ProfileIconView(profile: profile)
                                        .onTapGesture {
                                            viewModel.profileTapped(profile: profile)
                                        }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                Spacer()
                
                // --- Add User Button ---
                VStack {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.gray)
                    
                    Text("Add User")
                        .font(.headline)
                }
                .onTapGesture {
                    viewModel.addUserTapped()
                }
                .padding(.bottom, 40)
            } else {
                // 3. If not loading and should be onboarding, show a blank view
                //    while the sheet is being presented.
                Spacer()
            }
        }
        // --- Add sheet modifier for onboarding ---
        .sheet(isPresented: $viewModel.shouldShowOnboarding, onDismiss: {
            // When the sheet is dismissed, tell the ViewModel to fetch the profiles again.
            viewModel.fetchProfiles()
        }) {
            ParentOnboardingView()
        }
    }
}

// MARK: - Preview

// struct UserSelectionView_Previews: Provider {
struct UserSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        UserSelectionView()
    }
}
