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
        NavigationView {
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
                                        ForEach(viewModel.parentProfiles) { profile in
                                            // --- Use a direct NavigationLink for each parent profile ---
                                            NavigationLink(
                                                destination: ParentDashboardView(familyID: viewModel.familyID ?? ""),
                                                tag: profile.id ?? "",
                                                selection: $viewModel.navigationSelection
                                            ) {
                                                ProfileIconView(profile: profile)
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
                                        ForEach(viewModel.childProfiles) { profile in
                                            // Child profiles are buttons for now
                                            Button(action: {
                                                print("\(profile.name) tapped")
                                            }) {
                                                ProfileIconView(profile: profile)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                } else {
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $viewModel.shouldShowOnboarding) {
                ParentOnboardingView()
            }
        }
    }
}

// MARK: - Preview

struct UserSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        UserSelectionView()
    }
}
