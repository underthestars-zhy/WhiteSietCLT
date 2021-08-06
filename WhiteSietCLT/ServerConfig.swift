//
//  ServerConfig.swift
//  ServerConfig
//
//  Created by 朱浩宇 on 2021/8/6.
//

import Foundation
import ObjectMapper

struct ServerConfig: Mappable {
    var version: String = Info.vesion
    var serverName: String!
    
    
    init?(map: Map) { }
    
    convenience init() {
        self.init(map: Map(mappingType: .toJSON, JSON: [:]))
    }
    
    mutating func mapping(map: Map) {
        version <- map["version"]
        serverName <- map["serverName"]
    }
}
