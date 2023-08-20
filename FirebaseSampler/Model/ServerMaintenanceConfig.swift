//
//  ServerMaintenanceConfig.swift
//  FirebaseSampler
//
//  Created by N. M on 2023/08/14.
//

import Foundation

struct ServerMaintenanceConfig: Codable {
    var isUnderMaintenance = false
    var reason = ""
}
