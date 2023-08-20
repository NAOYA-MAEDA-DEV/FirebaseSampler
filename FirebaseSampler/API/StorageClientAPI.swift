//
//  StorageClientAPI.swift
//  FirebaseSampler
//
//  Created by N. M on 2023/08/15.
//

import Foundation
import FirebaseStorage
import FirebaseAuth
import UIKit

protocol StorageClientAPIProtocol {
    func downloadImage(of user: User, completion: @escaping (Result<UIImage, Error>) -> ())
    func upload(image: UIImage, user: User, completion: @escaping (Result<Void, Error>) -> ())
}

final class StorageClientAPI: StorageClientAPIProtocol {
    /// 画像をダウンロードする
    /// - Parameters:
    ///   - user: ユーザ情報
    ///   - completion: 画像のダウンロード後に実行するクロージャ   
    func downloadImage(of user: User, completion: @escaping (Result<UIImage, Error>) -> ()) {
        let path = "users/\(user.uid)/profile.jpg"
        
        let storage = Storage.storage()
        let reference = storage.reference()
        let imageRef = reference.child(path)
        
        imageRef.getData(maxSize: 15 * 1024 * 1024) { data, error in
            if let _error = error {
                completion(.failure(_error))
            } else {
                completion(.success(UIImage(data: data!)!))
            }
        }
    }
    
    /// 画像をアップロードする
    /// - Parameters:
    ///   - image: アップロードしたい画像
    ///   - user: ユーザ情報
    ///   - completion: 画像のアップロード後に実行するクロージャ
    func upload(image: UIImage, user: User, completion: @escaping (Result<Void, Error>) -> ()) {
        let path = "users/\(user.uid)/profile.jpg"
        let imageData = image.jpegData(compressionQuality: 1)!
        
        let storage = Storage.storage()
        let reference = storage.reference()
        let imageRef = reference.child(path)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        imageRef.putData(imageData, metadata: metadata) { (metaData, error) in
            if let _error = error {
                completion(.failure(_error))
            } else {
                completion(.success(()))
            }
        }
    }
}
