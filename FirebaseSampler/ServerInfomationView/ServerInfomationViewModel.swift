//
//  GetServerStateViewModel.swift
//  FirebaseSampler
//
//  Created by N. M on 2023/08/14.
//

import Foundation

final class ServerInfomationViewModel: ObservableObject {
    @Published var alertTitle = "" // アラートのタイトル
    @Published var alertMessage = "" // アラートの本文
    @Published var stateMessage = "" // バリデーションエラーメッセージ
    @Published var appVersionMessage = ""// バリデーションエラーメッセージ
    
    @Published var isProcessing = false // 処理中フラグ
    @Published var isShowingAlert = false // アラート表示フラグ
    
    var api: RemoteConfigClientAPIProtocol?
    
    /// RemoteConfigClientAPIProtocolプロトコルに準拠したオブジェクトを注入する
    /// - Parameters:
    ///   - api: RemoteConfigClientAPIProtocolプロトコルに準拠したオブジェクト
    func inject(api: RemoteConfigClientAPIProtocol) {
        self.api = api
    }
    
    /// サーバの状態を取得する
    func getServerState() {
        guard let _api = api else { return }
        isProcessing = true
        _api.fetchServerMaintenanceConfig{ [weak self] result in
            guard let _self = self else { return }
            _self.isProcessing = false
            _self.serverState(result: result)
        }
    }
    
    /// リリース中の最新アプリバージョンを取得する
    func getLatestAppVersion() {
        guard let _api = api else { return }
        isProcessing = true
        _api.fetchLatestAppVersionConfig{ [weak self] result in
            guard let _self = self else { return }
            _self.isProcessing = false
            _self.latestAppVersion(result: result)
        }
    }
    
    /// サーバの状態取得結果をアラートで表示する
    /// - Parameters:
    ///   - result: 取得結果
    private func serverState(result: Result<ServerMaintenanceConfig, Error>) {
        isShowingAlert = true
        switch result {
        case .success(let config):
            alertTitle = "Success"
            alertMessage = ""
            if config.isUnderMaintenance {
                stateMessage = config.reason
            } else {
                stateMessage = "Server is ok"
            }
        case .failure(let error):
            alertTitle = "Failed"
            alertMessage = error.localizedDescription
        }
    }
    
    /// リリース中の最新アプリバージョン取得結果をアラートで表示する
    /// - Parameters:
    ///   - result: 取得結果
    private func latestAppVersion(result: Result<String, Error>) {
        isShowingAlert = true
        switch result {
        case .success(let versionStr):
            alertTitle = "Success"
            alertMessage = ""
            appVersionMessage = versionStr
        case .failure(let error):
            alertTitle = "Failed"
            alertMessage = error.localizedDescription
        }
    }
}
