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
    
    enum LaunchDestination: Identifiable {
        case login
        case dashboard
        
        var id: Int {
            self.hashValue
        }
    }
    
    @Published var destination: LaunchDestination? = nil
    
    // This handle will keep a reference to our authentication listener.
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        listenForAuthStateChanges()
    }
    
    deinit {
        // It's important to remove the listener when the view model is no longer needed.
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    // MARK: - Public Methods
    
    /// Sets up a listener that continuously monitors the Firebase authentication state.
    func listenForAuthStateChanges() {
        // This closure is called automatically by Firebase whenever a user signs in or out.
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            // We add a small delay to prevent a jarring UI flash on launch.
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                if user != nil {
                    // If a user exists, navigate to the dashboard.
                    self?.destination = .dashboard
                } else {
                    // If no user is logged in, navigate to the login screen.
                    self?.destination = .login
                }
            }
        }
    }
}
