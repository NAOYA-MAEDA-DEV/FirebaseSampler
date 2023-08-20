//
//  TodoListViewModel.swift
//  FirebaseSampler
//
//  Created by N. M on 2023/08/13.
//

import Foundation

final class TodoListViewModel: ObservableObject {
    @Published var todoList: [TodoModel] = [] // Todoリスト
    
    @Published var alertTitle = "" // アラートのタイトル
    @Published var alertMessage = "" // アラートの本文
    
    @Published var isProcessing = false // 処理中フラグ
    @Published var isShowingAlert = false // アラート表示フラグ
    @Published var isShowSignInView = false
    
    var api: CloudFireStoreClientAPI?
    
    /// CloudFireStoreClientAPIProtocolに準拠したオブジェクトを注入する
    /// - Parameters:
    ///   - api: CloudFireStoreClientAPIProtocolに準拠したオブジェクト
    func inject(api: CloudFireStoreClientAPI) {
        self.api = api
    }
    
    /// サインイン中アカウントのTodoリストをサーバからダウンロードする
    func getTodoList() {
        guard let _api = api, let _user = AuthManager.shared.user else { return }
        isProcessing = true
        _api.downloadTodoList(of: _user) { [weak self] result in
            guard let _self = self else { return }
            _self.isProcessing = false
            switch result {
            case .failure(_):
                break
            case .success(let todoList):
                _self.todoList = todoList
            }
        }
    }
    
    /// Todoを追加してサーバに保存する
    func addTodo() {
        if let _user = AuthManager.shared.user {
            todoList.append(TodoModel())
            api!.upload(todo: todoList.last!, user: _user) { _ in }
        } else {
            alertMessage = "You must be signed in to add todos."
            isShowingAlert = true
        }
    }
}
