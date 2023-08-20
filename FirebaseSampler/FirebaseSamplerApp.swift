//
//  FirebaseSamplerApp.swift
//  FirebaseSampler
//
//  Created by N. M on 2023/08/12.
//

import SwiftUI
import Firebase
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

@main
struct FirebaseSamplerApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            FireBaseSampleListView()
                .environmentObject(AuthManager.shared)
        }
    }
}
