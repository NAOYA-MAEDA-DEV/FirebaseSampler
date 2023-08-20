//
//  FillButton.swift
//  FirebaseSampler
//
//  Created by N. M on 2023/08/12.
//

import SwiftUI

/// Fillボタンを表示する
/// - Parameters:
///   - label: アップロードするTodoデータ
///   - fillColor: ユーザ情報
///   - disabled: アップロード後に実行するクロージャ
///   - completion: ボタンをタップした後に実行するクロージャ
/// - Returns : Fillボタン
struct FillButton: View {
    var label = ""
    var fillColor = Color.blue
    var disabled = false
    var completion: () -> () = {}
    
    var body: some View {
        Button(action: {
            completion()
        }, label: {
            Text(label)
                .font(.system(size: 17))
                .frame(maxWidth: 500)
        })
        .padding(.horizontal, 15)
        .padding(.vertical, 15)
        .background(disabled ? .gray : fillColor)
        .accentColor(Color.white)
        .cornerRadius(30)
        .padding(.horizontal, 40)
    }
}

struct FillButton_Previews: PreviewProvider {
    static var previews: some View {
        FillButton(label: "SignIn", fillColor: .blue, disabled: false) {
            
        }
        .previewLayout(.sizeThatFits)
    }
}
