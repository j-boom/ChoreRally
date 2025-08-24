//
//  LaunchView.swift
//  ChoreRallyApp
//
//  Created by Gemini on [Date].
//
//  This view is the initial entry point of the app. It displays a loading
//  state while its ViewModel checks for an existing user session. Based on the
//  result, it will navigate the user to the appropriate screen.
//

import SwiftUI

struct LaunchView: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel = LaunchViewModel()
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Background color or image could go here
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack {
                Text("ChoreRally")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                ProgressView()
                    .padding(.top, 20)
            }
        }
        // When the view appears, it tells the ViewModel to start its check.
        .onAppear {
            viewModel.checkAuthenticationState()
        }
        // This presents the correct destination view as a full-screen modal
        // once the ViewModel determines where to go.
        .fullScreenCover(item: $viewModel.destination) { destination in
            switch destination {
            case .login:
                ParentLoginView()
            case .dashboard:
                UserSelectionView()
            }
        }
    }
}

// MARK: - Preview

struct LaunchView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchView()
    }
}
