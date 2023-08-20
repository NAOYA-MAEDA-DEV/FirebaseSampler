//
//  TodoDetailViewModel.swift
//  FirebaseSampler
//
//  Created by N. M on 2023/08/13.
//

import Foundation

final class TodoDetailViewModel: ObservableObject {
    @Published var title = ""
    @Published var detail = ""
    @Published var todo = TodoModel()
    
    @Published var isProcessing = false
    @Published var isShowingAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    
    var api: CloudFireStoreClientAPIProtocol?
    
    /// CloudFireStoreClientAPIProtocolに準拠したオブジェクトを注入する
    /// - Parameters:
    ///   - api: CloudFireStoreClientAPIProtocolに準拠したオブジェクト
    func inject(todo: TodoModel, api: CloudFireStoreClientAPIProtocol) {
        self.todo = todo
        self.api = api
        title = todo.title
        detail = todo.detail
    }
    
    /// Todoを削除する
    func delete() {
        guard let _api = api, let _user = AuthManager.shared.user else { return }
        isProcessing = true
        _api.delete(todo: todo, user: _user) { [weak self] result in
            guard let _self = self else { return }
            _self.isProcessing = false
            _self.resultAlert(result: result)
        }
    }
    
    /// Todoを保存する
    func save() {
        guard let _api = api, let _user = AuthManager.shared.user else { return }
        isProcessing = true
        todo.update(title: title)
        todo.update(detail: detail)
        _api.update(todo: todo, user: _user) { [weak self] result in
            guard let _self = self else { return }
            _self.isProcessing = false
            _self.resultAlert(result: result)
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
