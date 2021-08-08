//
//  FileHelper.swift
//  FileHelper
//
//  Created by 朱浩宇 on 2021/8/5.
//

import Foundation

class FileHelper {
    static var share = FileHelper()
    static let fileManager = FileManager.default
    let fileManager = FileManager.default
    
    private var _userDataURL: URL?
    private var _userServerConfigURL: URL?
    
    var userDataURL: URL {
        get {
            if let _userDataURL = _userDataURL {
                return _userDataURL
            } else {
                if let libraryURL = fileManager.urls(for: .libraryDirectory, in: .allDomainsMask).first {
                    let dataURL = libraryURL.appendingPathComponent("WhiteSiteCLT", isDirectory: true)
                    if !fileManager.fileExists(atPath: dataURL.path) {
                        do {
                            try fileManager.createDirectory(at: dataURL, withIntermediateDirectories: true)
                        } catch {
                            fatalError(error.localizedDescription)
                        }
                    }
                    
                    _userDataURL = dataURL
                    return dataURL
                } else {
                    fatalError("Cannot get user data url(path)")
                }
            }
        }
    }
    
    var userServerConfigURL: URL {
        get {
            if let _userServerConfigURL = _userServerConfigURL {
                return _userServerConfigURL
            } else {
                let configURL = userDataURL.appendingPathComponent("server_config", isDirectory: true)
                
                if !fileManager.fileExists(atPath: configURL.path) {
                    do {
                        try fileManager.createDirectory(at: configURL, withIntermediateDirectories: true)
                    } catch {
                        fatalError(error.localizedDescription)
                    }
                }
                
                _userServerConfigURL = configURL
                return configURL
            }
        }
    }
    
    init() {}
    
    func writeServerConfig(_ config: ServerConfig) {
        fileManager.createFile(atPath: userServerConfigURL.appendingPathComponent("\(config.serverName!).json").path, contents: config.toJSONString()?.data(using: .utf8), attributes: nil)
    }
}
