//
//  Manager.swift
//  Manager
//
//  Created by 朱浩宇 on 2021/8/5.
//

import Foundation
import Shout

class Manager {
    static let share = Manager()
    
    let fileManager = FileManager.default
    let userDataPath = { () -> URL in
        if let libraryURL = FileManager.default.urls(for: .libraryDirectory, in: .allDomainsMask).first {
            let dataURL = libraryURL.appendingPathComponent("WhiteSiteCLT", isDirectory: true)
            if !FileManager.default.fileExists(atPath: dataURL.path) {
                do {
                    try FileManager.default.createDirectory(at: dataURL, withIntermediateDirectories: false)
                } catch {
                    fatalError(error.localizedDescription)
                }
            }
            
            return dataURL
        } else {
            fatalError("Cannot get user data url(path)")
        }
    }()
    
    init() {
        
    }
    
    // MARK: - Instruction processing
    
    func new(with argument: String) {
        guard let type = NewType(rawValue: argument) else { fatalError("Invalid instruction") }
        
        switch type {
        case .server:
            creatServer()
        case .config:
            creatConfig()
        }
    }
    
    func remove() {
        
    }
    
    func edit() {
        
    }
    
    func `open`() {
        
    }
    
    // MARK: - Creat
    
    func creatServer() {
        
    }
    
    func creatConfig() {
        // TODO: Creat config file
    }
}
