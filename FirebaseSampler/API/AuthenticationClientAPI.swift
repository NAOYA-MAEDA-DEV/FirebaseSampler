//
//  AuthenticationClientAPI.swift
//  FirebaseSampler
//
//  Created by N. M on 2023/08/14.
//

import Foundation
import Firebase
import FirebaseAuth
import GoogleSignIn

protocol AuthenticationClientAPIProtocol {
    func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void)
    func signInwithGoogle(completion: @escaping (Result<Void, Error>) -> Void)
    func signOut() -> Result<Void, Error>
    func createAccount(email: String, password: String, name: String, completion: @escaping (Result<Void, Error>) -> Void)
    func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void)
    func resetPassword(email: String, completion: @escaping (Result<Void, Error>) -> Void)
    func sendEmailVerification(completion: @escaping (Result<Void, Error>) -> Void)
    func checkEmailVerification(completion: @escaping (Result<Bool, Error>) -> Void)
}

final class AuthenticationClientAPI {
    /// サインインを行う
    /// - Parameters:
    ///   - email: サインインに使用するメールアドレス
    ///   - password: サインインに使用するパスワード
    ///   - completion: サインイン処理後に実行するクロージャ
    func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let _error = error {
                completion(.failure(_error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    /// Googleアカウントでサインインを行う
    ///   - completion: メールアドレス確認用メールを送信後に実行するクロージャ
    func signInwithGoogle(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID,
              let scenes = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = scenes.windows.first?.rootViewController else {
            fatalError()
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        GIDSignIn.sharedInstance.signIn(withPresenting: root) { result, error in
            if let _error = error {
                completion(.failure(_error))
                return
            }
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString
            else {
                fatalError()
            }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,accessToken: user.accessToken.tokenString)
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let _error = error {
                    completion(.failure(_error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
    
    /// サインアウトを行う
    /// - Returns : 実行結果
    func signOut() -> Result<Void, Error> {
        do {
            try Auth.auth().signOut()
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    /// アカウント作成を行う
    /// - Parameters:
    ///   - email: アカウントに設定するメールアドレス
    ///   - password: アカウントに設定するパスワード
    ///   - name: アカウントに設定する名前
    ///   - completion: アカウント作成後に実行するクロージャ
    func createAccount(email: String, password: String, name: String = "Anonymous", completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let user = result?.user {
                let request = user.createProfileChangeRequest()
                request.displayName = name
                request.commitChanges { error in
                    if let _error = error {
                        completion(.failure(_error))
                    } else {
                        user.sendEmailVerification() { error in
                            if let _error = error {
                                completion(.failure(_error))
                            } else {
                                completion(.success(()))
                            }
                        }
                    }
                }
            } else if let _error = error {
                completion(.failure(_error))
            }
        }
    }
    
    /// アカウントの削除を行う
    /// - Parameters:
    ///   - completion: アカウントの削除後に実行するクロージャ
    func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        if let user = Auth.auth().currentUser {
            user.delete() { error in
                if let _error = error {
                    completion(.failure(_error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
    
    /// パスワードのリセットを行うためのメールを送信する
    /// - Parameters:
    ///   - email: パスワードをリセットするアカウントのメールアドレス
    ///   - completion: パスワードをリセット後に実行するクロージャ
    func resetPassword(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let _error = error {
                completion(.failure(_error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    /// メールアドレス確認用メールを送信する
    ///   - completion: メールアドレス確認用メールを送信後に実行するクロージャ
    func sendEmailVerification(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let _user = Auth.auth().currentUser else { return }
        _user.sendEmailVerification { error in
            if let _error = error {
                completion(.failure(_error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    /// メールアドレスの確認状況を調査する
    ///   - completion:調査後に実行するクロージャ
    func checkEmailVerification(completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let _user = Auth.auth().currentUser else { return }
        _user.reload { error in
            if let _error = error {
                completion(.failure(_error))
            } else {
                completion(.success(_user.isEmailVerified))
            }
        }
    }
}


