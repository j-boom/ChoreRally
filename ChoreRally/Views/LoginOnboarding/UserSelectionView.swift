//
//  UserSelectionView.swift
//  ChoreRally
//
//  This view has been refactored to use consistent NavigationLinks for both
//  parent and child dashboards.
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
                // The main body is now much simpler.
                if viewModel.isLoading {
                    loadingView
                } else {
                    mainContentView
                }
                
                // The logout button is overlaid on top.
                logoutButton
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $viewModel.shouldShowOnboarding, onDismiss: {
                viewModel.fetchInitialData()
            }) {
                ParentOnboardingView()
            }
            .sheet(item: $viewModel.profileForPinEntry) { _ in
                pinEntrySheet
            }
            // The .fullScreenCover has been removed from here.
        }
    }
    
    // MARK: - Subviews
    
    /// The view to display while data is loading.
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
            Spacer()
        }
    }
    
    /// The main content of the screen with the profile selections.
    private var mainContentView: some View {
        VStack {
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
                    parentProfilesGrid
                    childProfilesGrid
                }
                .padding(.horizontal)
            }
        }
    }
    
    /// The grid of parent profiles.
    @ViewBuilder
    private var parentProfilesGrid: some View {
        if !viewModel.parentProfiles.isEmpty {
            VStack(alignment: .leading) {
                Text("Parents")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(viewModel.parentProfiles) { profile in
                        Button(action: {
                            viewModel.profileForPinEntry = profile
                        }) {
                            ProfileIconView(profile: profile)
                        }
                    }
                }
            }
        }
    }
    
    /// The grid of child profiles.
    @ViewBuilder
    private var childProfilesGrid: some View {
        if !viewModel.childProfiles.isEmpty {
            VStack(alignment: .leading) {
                Text("Children")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(viewModel.childProfiles) { profile in
                        // CHANGED: This is now a NavigationLink.
                        NavigationLink(destination: ChildDashboardView(childProfile: profile, familyID: viewModel.familyID ?? "")) {
                            ProfileIconView(profile: profile)
                        }
                    }
                }
            }
        }
    }
    
    /// The view for entering a PIN.
    private var pinEntrySheet: some View {
        VStack {
            ParentPinView(title: "Enter PIN", onPinEntered: viewModel.verifyPin)
            
            if let errorMessage = viewModel.pinErrorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
    }
    
    /// The logout button that overlays the view.
    @ViewBuilder
    private var logoutButton: some View {
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
