//
//  PluginConfig.swift
//  PluginConfig
//
//  Created by 朱浩宇 on 2021/8/11.
//

import Foundation
import ObjectMapper

struct PluginConfig: Mappable {
    var version: String = Info.pluginConfigVersion
    var name: String!
    var executeName: String!
    var execute: PluginExecute?
    
    init?(map: Map) {}
    init() {}
    
    mutating func mapping(map: Map) {
        version <- map["version"]
        name <- map["name"]
        executeName <- map["executeName"]
        execute <- map["execute"]
    }
}

struct PluginExecute: Mappable {
    init?(map: Map) {}
    init() {}
    
    mutating func mapping(map: Map) {
        
    }
}
