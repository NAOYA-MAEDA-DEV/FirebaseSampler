//
//  RemoteConfigClientAPI.swift
//  FirebaseSampler
//
//  Created by N. M on 2023/08/14.
//

import Foundation
import Firebase
import FirebaseRemoteConfig

protocol RemoteConfigClientAPIProtocol {
    func fetchServerMaintenanceConfig(completion: @escaping (Result<ServerMaintenanceConfig, Error>) -> ())
    func fetchLatestAppVersionConfig(completion: @escaping (Result<String, Error>) -> ())
}

final class RemoteConfigClientAPI : RemoteConfigClientAPIProtocol {
    private var remoteConfig: RemoteConfig
    
    init() {
        remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.fetchTimeout = 30
        #if DEBUG
        settings.minimumFetchInterval = 0
        #endif
        remoteConfig.configSettings = settings
    }
    
    /// サーバーのメンテナンス状況を取得する
    /// - Parameters:
    ///   - completion: サーバーのメンテナンス状況取得後に実行するクロージャ
    func fetchServerMaintenanceConfig(completion: @escaping (Result<ServerMaintenanceConfig, Error>) -> ()) {
        remoteConfig.fetchAndActivate { [weak self] status, error in
            switch status {
            case .successFetchedFromRemote, .successUsingPreFetchedData:
                guard let jsonString = self?.remoteConfig[KEY_SERVER_MAINTENANCE_CONFIG].stringValue,
                   let data = jsonString.data(using: .utf8) else {
                    completion(.failure(ConfigError.parseError))
                    return
                }
                do {
                    let config = try JSONDecoder().decode(ServerMaintenanceConfig.self, from: data)
                    completion(.success(config))
                } catch (let error) {
                    completion(.failure(error))
                }
            case .error:
                if let _error = error {
                    completion(.failure(_error))
                }
            @unknown default:
                completion(.failure(ConfigError.unknown))
            }
        }
    }
    
    /// アプリの最新バージョンを取得する
    /// - Parameters:
    ///   - completion: アプリの最新バージョン取得後に実行するクロージャ
    func fetchLatestAppVersionConfig(completion: @escaping (Result<String, Error>) -> ()) {
        remoteConfig.fetchAndActivate { [weak self] status, error in
            switch status {
            case .successFetchedFromRemote, .successUsingPreFetchedData:
                let appVersionStr = self?.remoteConfig[KEY_LATEST_APP_VERSION_CONFIG].stringValue
                if let _appVersionStr = appVersionStr {
                    completion(.success(_appVersionStr))
                } else {
                    completion(.failure(ConfigError.parseError))
                }
            case .error:
                if let _error = error {
                    completion(.failure(_error))
                }
            @unknown default:
                completion(.failure(ConfigError.unknown))
            }
        }
    }
}

/// Config取得失敗用のエラー
enum ConfigError: Error {
    case parseError
    case unknown
    
    var message: String {
        switch self {
        case .parseError:
            return "Failed to parse json data."
            
        case .unknown:
            return "An unexpected error has occurred"
        }
    }
}
