//
//  TodoModel.swift
//  FirebaseSampler
//
//  Created by N. M on 2023/08/13.
//

import FirebaseFirestoreSwift
import Foundation
import FirebaseAuth

/// Todoを表すモデルクラス
struct TodoModel: Codable {
    var id: String = UUID().uuidString // ドキュメントID
    private(set) var title = "" // Todoのタイトル
    private(set) var detail = "" // Todoの詳細内容
    private(set) var createDate = Date() // Todoデータ作成日
    private(set) var updateDate = Date() // Todoデータップデート日に
    
    mutating func update(title: String) {
        self.title = title
    }
    
    mutating func update(detail: String) {
        self.detail = detail
    }
}
