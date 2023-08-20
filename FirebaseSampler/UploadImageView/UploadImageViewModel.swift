//
//  ChangeProfileIconViewModel.swift
//  FirebaseSampler
//
//  Created by N. M on 2023/08/15.
//

import Foundation
import _PhotosUI_SwiftUI

final class UploadImageViewModel: ObservableObject {
    @Published var profileIconImage: UIImage?
    
    var selectedPhoto: PhotosPickerItem? {
        didSet {
            if let selectedPhoto {
                loadTransfereble(photo: selectedPhoto)
            } else {
                profileIconImage = nil
            }
        }
    }
    
    @Published var alertTitle = "" // アラートのタイトル
    @Published var alertMessage = "" // アラートの本文
    @Published var errorMessage = "" // バリデーションエラーメッセージ
    
    @Published var isSignUpButtonEnabled = false // サインアップボタンの活性化状態
    @Published var isProcessing = false // 処理中フラグ
    @Published var isShowingAlert = false // アラート表示フラグ
    
    private var api: StorageClientAPIProtocol?
    
    /// StorageClientAPIProtocolに準拠したオブジェクトを注入する
    /// - Parameters:
    ///   - api: StorageClientAPIProtocolに準拠したオブジェクト
    func inject(api: StorageClientAPIProtocol) {
        self.api = api
    }
    
    private func loadTransfereble(photo: PhotosPickerItem) {
        isProcessing = true
        photo.loadTransferable(type: Data.self) { [weak self] result in
            DispatchQueue.main.async {
                guard let _self = self else { return }
                switch result {
                case .success(let data):
                    if let data, let _image = UIImage(data: data) {
                        _self.profileIconImage = _image
                    }
                case .failure(let error):
                    print(error)
                }
                _self.isProcessing = false
            }
        }
    }
    
    /// 画像をサーバからダウンロードする
    func downloadProfileIconImage() {
        isProcessing = true
        guard let _api = api, let _user = AuthManager.shared.user else { return }
        _api.downloadImage(of: _user) { [weak self] result in
            guard let _self = self else { return }
            _self.isProcessing = false
            switch result {
            case .success(let image):
                _self.profileIconImage = image
            case .failure:
                _self.profileIconImage = nil
            }
        }
    }
    
    /// 画像をサーバにアップロードする
    func uploadProfileIconImage() {
        isProcessing = true
        guard let _api = api, let _user = AuthManager.shared.user, let image = profileIconImage else { return }
        _api.upload(image: image, user: _user) { [weak self] result in
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
