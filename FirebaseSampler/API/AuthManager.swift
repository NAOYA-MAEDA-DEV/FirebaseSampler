//
//  AuthSettingsManager.swift
//  FirebaseSampler
//
//  Created by N. M on 2023/08/12.
//

import Foundation
import FirebaseAuth

final class AuthManager: ObservableObject {
    private var listener: AuthStateDidChangeListenerHandle!
    
    static let shared: AuthManager = .init()
    
    @Published var user: User?
    @Published var userName = ""
    @Published var isEmailVerified = false
    
    init() {
        self.listener = Auth.auth().addStateDidChangeListener { [weak self] (_, user) in
            if let _user = user {
                self?.user = _user
                self?.userName = _user.displayName ?? "Anonymous"
                self?.isEmailVerified = _user.isEmailVerified
            } else {
                self?.user = nil
                self?.userName = "Anonymous"
                self?.isEmailVerified = false
            }
        }
    }
    
    deinit {
        Auth.auth().removeStateDidChangeListener(listener!)
    }
}

