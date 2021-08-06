//
//  ServerConfig.swift
//  ServerConfig
//
//  Created by 朱浩宇 on 2021/8/6.
//

import Foundation
import ObjectMapper

struct ServerConfig: Mappable {
    var version: String = Info.serverConfigVersion
    var serverName: String!
    var ip: String!
    
    
    init?(map: Map) { }
    
    init?() {
        self.init(map: Map(mappingType: .fromJSON, JSON: ["version" : Info.serverConfigVersion]))
    }
    
    mutating func mapping(map: Map) {
        version <- map["version"]
        serverName <- map["serverName"]
        ip <- map["ip"]
    }
}
