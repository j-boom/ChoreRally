//
//  ChoreRallyApp.swift
//  ChoreRally
//
//  Created by Jim Bergren on 8/23/25.
//

import SwiftUI
import FirebaseCore

// This class handles application-level events. We're using it to configure Firebase.
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    // This line connects your app to your Firebase project when the app starts.
    FirebaseApp.configure()
    return true
  }
}

@main
struct ChoreRallyApp: App {
  // This line registers your AppDelegate class with the SwiftUI app lifecycle.
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

  var body: some Scene {
    WindowGroup {
        // This sets our LaunchView as the very first screen the user sees.
        LaunchView()
    }
  }
}
