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
    
    init?(map: Map) {}
    init() {}
    
    mutating func mapping(map: Map) {
        version <- map["version"]
        name <- map["name"]
    }
}
