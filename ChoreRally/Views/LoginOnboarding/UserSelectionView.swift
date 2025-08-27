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
    
    @StateObject private var viewModel = UserSelectionViewModel()
    
    let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 120))
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // --- Main Content ---
                VStack {
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView()
                        Spacer()
                    } else {
                        // This invisible NavigationLink is triggered by the viewModel
                        // after a successful PIN entry.
                        if let familyID = viewModel.familyID {
                            NavigationLink(
                                destination: ParentDashboardView(familyID: familyID),
                                tag: viewModel.navigationSelection ?? "",
                                selection: $viewModel.navigationSelection
                            ) { EmptyView() }
                        }
                        
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
                                                // Parent profiles are now buttons that trigger the PIN sheet.
                                                Button(action: {
                                                    viewModel.profileForPinEntry = profile
                                                }) {
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
                    }
                }
                .navigationBarHidden(true)
                // This will now correctly refresh the profile list after onboarding.
                .sheet(isPresented: $viewModel.shouldShowOnboarding, onDismiss: {
                    viewModel.fetchProfiles()
                }) {
                    ParentOnboardingView()
                }
                // This sheet presents the PIN view when a parent profile is tapped.
                .sheet(item: $viewModel.profileForPinEntry) { _ in
                    VStack {
                        ParentPinView(title: "Enter PIN", onPinEntered: viewModel.verifyPin)
                        
                        if let errorMessage = viewModel.pinErrorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .padding()
                        }
                    }
                }
                
                // --- Logout Button Overlay ---
                if !viewModel.isLoading {
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                viewModel.logout()
                            }) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                                    .padding()
                            }
                        }
                        Spacer()
                    }
                }
            }
        }
    }
}
