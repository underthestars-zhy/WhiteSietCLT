//
//  Info.swift
//  Info
//
//  Created by 朱浩宇 on 2021/8/6.
//

import Foundation
import ObjectMapper

struct Info {
    static let version = "1.0.0"
    static let serverConfigVersion = "1.0.0"
    static let pluginConfigVersion = "1"
    static let innerPlugins = ["pm"]
}

struct InfoData: Mappable {
    var version: String = Info.version
    
    init?(map: Map) {}
    init() {}
    
    mutating func mapping(map: Map) {
        version <- map["vsersion"]
    }
}
