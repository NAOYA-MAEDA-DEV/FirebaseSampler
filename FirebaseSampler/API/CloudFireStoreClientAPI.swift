//
//  CloudFireStoreAPI.swift
//  FirebaseSampler
//
//  Created by N. M on 2023/08/13.
//

import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

protocol CloudFireStoreClientAPIProtocol {
    func downloadTodoList(of user: User, completion: @escaping (Result<[TodoModel], Error>) -> Void)
    func upload(todo: TodoModel, user: User, completion: @escaping (Result<Void, Error>) -> Void)
    func update(todo: TodoModel, user: User, completion: @escaping (Result<Void, Error>) -> Void)
    func delete(todo: TodoModel, user: User, completion: @escaping (Result<Void, Error>) -> Void)
}

final class CloudFireStoreClientAPI: CloudFireStoreClientAPIProtocol {
    /// Todoデータリストをサーバからダウンロードする
    /// - Parameters:
    ///   - todo: ダウンロードするTodoデータ
    ///   - user: ユーザ情報
    ///   - completion: Todoデータリストをダウンロード後に実行するクロージャ
    func downloadTodoList(of user: User, completion: @escaping (Result<[TodoModel], Error>) -> Void) {
        Firestore.firestore().collection("users/\(user.uid)/todos").getDocuments{ snapShots, error in
            if let _error = error {
                completion(.failure(_error))
            } else {
                if let _snapShots = snapShots {
                    let documents = _snapShots.documents
                    var todoList: [TodoModel] = documents.compactMap {
                        return try? $0.data(as: TodoModel.self)
                    }
                    todoList.sort { $0.createDate < $1.createDate }
                    completion(.success(todoList))
                }
            }
        }
    }
    
    /// Todoデータをサーバにアップロードする
    /// - Parameters:
    ///   - todo: アップロードするTodoデータ
    ///   - user: ユーザ情報
    ///   - completion: Todoデータをアップロード後に実行するクロージャ
    func upload(todo: TodoModel, user: User, completion: @escaping (Result<Void, Error>) -> Void) {
        let createdTime = FieldValue.serverTimestamp()
        Firestore.firestore().collection("users/\(user.uid)/todos").document(user.uid + todo.id).setData(
            [
                KEY_TODO_ID: todo.id,
                KEY_TODO_TITLE: todo.title,
                KEY_TODO_DETAIL: todo.detail,
                KEY_TODO_CREATE_DATE: createdTime,
                KEY_TODO_UPDATE_DATE: createdTime,
            ],
            merge: true,
            completion: { error in
                if let _error = error {
                    completion(.failure(_error))
                } else {
                    completion(.success(()))
                }
            }
        )
    }
    
    /// Todoデータをアップデートする
    /// - Parameters:
    ///   - todo: アップデートするTodoデータ
    ///   - user: ユーザ情報
    ///   - completion: Todoデータをアップデート後に実行するクロージャ
    func update(todo: TodoModel, user: User, completion: @escaping (Result<Void, Error>) -> Void) {
        let createdTime = FieldValue.serverTimestamp()
        Firestore.firestore().collection("users/\(user.uid)/todos").document(user.uid + todo.id).updateData(
            [
                KEY_TODO_TITLE: todo.title,
                KEY_TODO_DETAIL: todo.detail,
                KEY_TODO_UPDATE_DATE: createdTime,
            ],
            completion: { error in
                if let _error = error {
                    completion(.failure(_error))
                } else {
                    completion(.success(()))
                }
            }
        )
    }
    
    /// Todoデータを削除する
    /// - Parameters:
    ///   - todo: 削除するTodoデータ
    ///   - user: ユーザ情報
    ///   - completion: Todoデータを削除後に実行するクロージャ
    func delete(todo: TodoModel, user: User, completion: @escaping (Result<Void, Error>) -> Void) {
        Firestore.firestore().collection("users/\(user.uid)/todos").document(user.uid + todo.id).delete() { error in
            if let _error = error {
                completion(.failure(_error))
            } else {
                completion(.success(()))
            }
        }
    }
}
