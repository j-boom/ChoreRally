//
//  LaunchViewModel.swift
//  ChoreRallyApp
//
//  Created by Gemini on [Date].
//
//  This ViewModel handles the logic for the LaunchView. Its sole responsibility
//  is to check the user's authentication status and publish a destination
//  for the view to navigate to.
//

import Foundation
import Combine
import FirebaseAuth

class LaunchViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    // This enum defines the possible destinations from the launch screen.
    // It conforms to 'Identifiable' so it can be used with .fullScreenCover.
    enum LaunchDestination: Identifiable {
        case login
        case dashboard
        
        var id: Int {
            self.hashValue
        }
    }
    
    // The view will listen for changes to this property. When it's set,
    // the fullScreenCover modifier will trigger.
    @Published var destination: LaunchDestination? = nil
    
    // MARK: - Public Methods
    
    /// Checks the authentication state of the user.
    func checkAuthenticationState() {
        // --- This is the real Firebase authentication check ---
        // Auth.auth().currentUser will be nil if no one is logged in.
        if Auth.auth().currentUser != nil {
            // If a user session exists, go to the dashboard.
            // We add a small delay to prevent a jarring UI flash on launch.
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.destination = .dashboard
            }
        } else {
            // If no user is logged in, go to the login screen.
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.destination = .login
            }
        }
    }
}
