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
    var userName: String!
    var password: String!
    var port: Int32!
    var system: System!
    var plugins: [String] = []
    
    
    init?(map: Map) {}
    init() {}
    
    mutating func mapping(map: Map) {
        version <- map["version"]
        serverName <- map["serverName"]
        ip <- map["ip"]
        userName <- map["userName"]
        password <- map["password"]
        port <- map["port"]
        system <- map["system"]
    }
}

enum System: String {
    case centos = "centos"
    case debian = "debian"
    case ubuntu = "ubuntu"
}
