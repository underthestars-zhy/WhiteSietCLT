//
//  Scheduler.swift
//  Scheduler
//
//  Created by 朱浩宇 on 2021/8/11.
//

import Foundation

struct Scheduler {
    let serverName: String
    var config: ServerConfig {
        willSet {
            FileHelper.share.writeServerConfig(newValue)
        }
    }
    
    init(_ serverName: String) {
        self.serverName = serverName
        self.config = FileHelper.share.getServerConfig(serverName)
    }
}
