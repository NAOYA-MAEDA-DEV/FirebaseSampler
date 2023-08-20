//
//  SignUpViewModel.swift
//  FirebaseSampler
//
//  Created by N. M on 2023/08/12.
//

import Combine
import Foundation

final class SignUpViewModel: ObservableObject {
    @Published var userNameStr = ""// ユーザネーム
    @Published var emailStr = "" // メールアドレス
    @Published var passwordStr = "" // パスワード
    @Published var confirmPasswordStr = "" // 確認用パスワード
    
    @Published var alertTitle = "" // アラートのタイトル
    @Published var alertMessage = "" // アラートの本文
    @Published var errorMessage = "" // バリデーションエラーメッセージ
    
    @Published var isSignUpButtonEnabled = false // サインアップボタンの活性化状態
    @Published var isProcessing = false // 処理中フラグ
    @Published var isShowingAlert = false // アラート表示フラグ
    
    private var anyCancellable = Set<AnyCancellable>()
    
    private var api: AuthenticationClientAPI?
    
    init() {
        // バリデーションチェック
        $userNameStr
            .combineLatest($emailStr, $passwordStr, $confirmPasswordStr)
            .map { userName, email, password, confirmPassword in
                guard userName.count > 3 || userName.count < 10 else { return false }
                guard VaridatorAPI.isValidEmail(string: email) else { return false }
                guard password.count > 5 || password.count < 10 else { return false }
                guard password == confirmPassword else { return false }
                return true
            }
            .assign(to: &$isSignUpButtonEnabled)
        
        // エラーメッセージ
        $userNameStr
            .combineLatest($emailStr, $passwordStr, $confirmPasswordStr)
            .debounce(for: 2, scheduler: RunLoop.main)
            .map { userName, email, password, confirmPassword in
                guard userName.isEmpty || userName.count > 3 && userName.count < 10 else {
                    return "Username must be at least 4 characters and less than 10 characters."
                }
                guard email.isEmpty || VaridatorAPI.isValidEmail(string: email) else {
                    return "Invalid email address."
                }
                guard password.isEmpty || password.count > 5 && password.count < 10 else {
                    return "Password must be at least 6 characters and less than 10 characters."
                }
                guard confirmPassword.isEmpty || password == confirmPassword else {
                    return "The confirmation password is incorrect."
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
    
    /// アカウントを作成する
    func createAccount() {
        guard let _api = api else { return }
        isProcessing = true
        _api.createAccount(email: emailStr, password: passwordStr, name: userNameStr) { [weak self] result in
            guard let _self = self else { return }
            _self.resultAlert(result: result)
            _self.isProcessing = false
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
