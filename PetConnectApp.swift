//
//  PetConnectApp.swift
//  PetConnect
//
//  Created by x7 on 2023/8/7.
//

import SwiftUI
import Firebase
import FirebaseCore
import FirebaseAuth

@main
struct PetConnectApp: App {
  // register app delegate for Firebase setup
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate


  var body: some Scene {
    WindowGroup {
      RootView()
    }
  }
}

class AppDelegate: NSObject, UIApplicationDelegate{
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

