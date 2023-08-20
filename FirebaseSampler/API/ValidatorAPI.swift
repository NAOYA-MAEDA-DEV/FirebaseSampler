//
//  VaridatorAPI.swift
//  FireBaseSample2
//
//  Created by N. M on 2023/08/12.
//

import Foundation

final class VaridatorAPI {
    /// 引数のメールアドレスを表す文字列のバリデーションを行う
    /// - Parameters:
    ///   - string: メールアドレスを表す文字列
    /// - Returns : バリデーション結果
    static func isValidEmail(string: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: string)
    }
}
