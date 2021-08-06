//
//  Manager.swift
//  Manager
//
//  Created by 朱浩宇 on 2021/8/5.
//

import Foundation
import Shout
import Darwin

class Manager {
    static let share = Manager()
    
    var w = winsize()
    
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
    
    private func creatServer() {
        print("(*) Representative must fill in, others can be skipped")
        printSplitLine()
        
        print("Server Name(*): ", terminator: "")
        guard let serverName = readLine() else { fatalError("Unavailable: serverName") }
        guard checkServerNameRepeat(serverName) else { fatalError("serverName") }
    }
    
    private func checkServerNameRepeat(_ name: String) -> Bool {
        do {
            let configURLs = try FileHelper.fileManager.contentsOfDirectory(atPath: FileHelper.share.userServerConfigURL.path)
            for path in configURLs {
                guard let url = URL(string: path) else { fatalError("internal error #1") }
                let fileName = (url.path as NSString).deletingPathExtension as String
                if name.trimmingCharacters(in: .whitespaces) == fileName.trimmingCharacters(in: .whitespaces) {
                    print(url.pathExtension.trimmingCharacters(in: .whitespaces))
                    return false
                }
            }
            
            return true
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func creatConfig() {
        // TODO: Creat config file
    }
    
    // MARK: - Tool
    
    private func printSplitLine(_ text: String = "=") {
        if ioctl(STDOUT_FILENO, TIOCGWINSZ, &w) == 0 {
            for _ in 0..<w.ws_col { print(text, terminator: "") }
            print("")
        }
    }
}


