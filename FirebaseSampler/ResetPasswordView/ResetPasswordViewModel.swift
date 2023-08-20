//
//  ResetPasswordViewModel.swift
//  FirebaseSampler
//
//  Created by N. M on 2023/08/12.
//

import Combine
import Foundation

final class ResetPasswordViewModel: ObservableObject {
    @Published var emailStr = "" // メールアドレス
    
    @Published var alertTitle = "" // アラートのタイトル
    @Published var alertMessage = "" // アラートの本文
    @Published var errorMessage = "" // バリデーションエラーメッセージ
    
    @Published var isResetButtonEnabled = false // リセットボタンの活性化状態
    @Published var isProcessing = false // 処理中フラグ
    @Published var isShowingAlert = false // アラート表示フラグ
    
    private var anyCancellable = Set<AnyCancellable>()
    
    var api: AuthenticationClientAPI?
    
    init() {
        // バリデーションチェック
        $emailStr
            .map { email in
                guard VaridatorAPI.isValidEmail(string: email) else { return false }
                return true
            }
            .assign(to: &$isResetButtonEnabled)
        
        // エラーメッセージ
        $emailStr
            .debounce(for: 2, scheduler: RunLoop.main)
            .map { email in
                guard email.isEmpty || VaridatorAPI.isValidEmail(string: email) else {
                    return "Invalid email address."
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
    
    /// 入力済みのメールアドレス宛にパスワードリセットメールを送信する
    func resetPassword() {
        guard let _api = api else { return }
        isProcessing = true
        _api.resetPassword(email: emailStr) { [weak self] result in
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
            alertMessage = "Send email."
        case .failure(let error):
            alertTitle = "Failed"
            alertMessage = error.localizedDescription
        }
    }
}
