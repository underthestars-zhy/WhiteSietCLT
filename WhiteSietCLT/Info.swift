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
    static let innerPluginsFile = [
        [
            "pm",
            #"""
            {
                "version": "1.0.0"
                "name": "pm",
                "executeName": "pm",
                "execute": null
            }
            """#
        ]
    ]
}

struct InfoData: Mappable {
    var version: String = Info.version
    
    init?(map: Map) {}
    init() {}
    
    mutating func mapping(map: Map) {
        version <- map["vsersion"]
    }
}
