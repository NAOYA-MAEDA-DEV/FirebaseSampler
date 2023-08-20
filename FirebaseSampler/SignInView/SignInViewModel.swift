//
//  SignInViewModel.swift
//  FirebaseSampler
//
//  Created by N. M on 2023/08/12.
//

import Foundation
import Combine

final class SignInViewModel: ObservableObject {
    @Published var emailStr = "" // メールアドレス
    @Published var passwordStr = "" // パスワード
    @Published var isVerified = true // メースアドレス認証状態
    
    @Published var alertTitle = "" // アラートのタイトル
    @Published var alertMessage = "" // アラートの本文
    @Published var errorMessage = "" // バリデーションエラーメッセージ
    
    @Published var isSignInButtonEnabled = false // サインインボタンの活性化状態
    @Published var isProcessing = false // 処理中フラグ
    @Published var isShowingAlert = false // アラート表示フラグ
    
    private var anyCancellable = Set<AnyCancellable>()
    
    private var api: AuthenticationClientAPI?
    
    init() {
        // バリデーションチェック
        $emailStr
            .combineLatest($passwordStr)
            .map { email, password in
                guard VaridatorAPI.isValidEmail(string: email) else { return false }
                guard password.count > 5 || password.count < 10 else { return false }
                return true
            }
            .assign(to: &$isSignInButtonEnabled)
        
        // エラーメッセージ
        $emailStr
            .combineLatest($passwordStr)
            .debounce(for: 2, scheduler: RunLoop.main)
            .map { email, password in
                guard email.isEmpty || VaridatorAPI.isValidEmail(string: email) else {
                    return "Invalid email address."
                }
                guard password.isEmpty || password.count > 5 && password.count < 10 else {
                    return "Password must be at least 6 characters and less than 10 characters."
                }
                return ""
            }
            .assign(to: &$errorMessage)
    }
    
    /// AuthenticationClientAPIProtocolに準拠したオブジェクトを注入する
    /// - Parameters:
    ///   - api: AuthenticationClientAPIProtocolに準拠したオブジェクト
    func inject(api: AuthenticationClientAPI) {
        self.api = api
    }
    
    /// サインインを行う
    func signIn() {
        guard let _api = api else { return }
        isProcessing = true
        _api.signIn(email: emailStr, password: passwordStr) { [weak self] result in
            guard let _self = self else { return }
            _self.resultAlert(result: result)
            _self.isProcessing = false
        }
    }
    
    /// サインアウトを行う
    func signOut() {
        guard let _api = api else { return }
        let result = _api.signOut()
        resultAlert(result: result)
    }
    
    /// Googleアカウントでサインインを行う
    func signInwtihGoogle() {
        guard let _api = api else { return }
        _api.signInwithGoogle { [weak self] result in
            guard let _self = self else { return }
            _self.resultAlert(result: result)
        }
    }
    
    /// サインイン中のアカウントを削除する
    func deleteAccount() {
        guard let _api = api else { return }
        isProcessing = true
        _api.deleteAccount { [weak self] result in
            guard let _self = self else { return }
            _self.resultAlert(result: result)
            _self.isProcessing = false
        }
    }
    
    /// メールアドレス確認用メールを送信する
    func sendEmailVerification() {
        guard let _api = api else { return }
        _api.sendEmailVerification { [weak self] result in
            guard let _self = self else { return }
            _self.resultAlert(result: result)
        }
    }
    
    /// メールアドレスの確認状況を調査する
    func checkEmailVerification() {
        guard let _api = api else { return }
        _api.checkEmailVerification{ [weak self] result in
            guard let _self = self else { return }
            switch result {
            case .success(let isVerified):
                _self.isVerified = isVerified
            case .failure(_):
                _self.isVerified = false
            }
        }
    }
    
    /// 処理結果をアラートで表示する
    /// - Parameters:
    ///   - result: 処理結果
    private func resultAlert(result: Result<Void, Error>) {
        isShowingAlert = true
        switch result {
        case .success(_):
            alertTitle = "Success"
            alertMessage = ""
        case .failure(let error):
            alertTitle = "Failed"
            alertMessage = error.localizedDescription
        }
    }
}
