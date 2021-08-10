//
//  Manager.swift
//  Manager
//
//  Created by 朱浩宇 on 2021/8/5.
//

import Foundation
import Shout
import Darwin
import Regex
import SwiftRandom

class Manager {
    static let share = Manager()
    
    var w = winsize()
    
    init() {
        
    }
    
    // MARK: - Instruction processing
    
    func new(with argument: String) {
        guard let type = EexcuteType(rawValue: argument) else { fatalError("Invalid instruction") }
        
        switch type {
        case .server: creatServer()
        case .config: creatConfig()
        }
    }
    
    func remove(with argument: String) {
        guard let type = EexcuteType(rawValue: argument) else { fatalError("Invalid instruction") }
        
        switch type {
        case .server: removeServer()
        case .config: removeConfig()
        }
    }
    
    func edit(with argument: String) {
        guard let type = EexcuteType(rawValue: argument) else { fatalError("Invalid instruction") }
        
        switch type {
        case .server: editServer()
        case .config: editConfig()
        }
    }
    
    func `open`() {
        
    }
    
    func list(for argument: String) {
        guard let type = EexcuteType(rawValue: argument) else { fatalError("Invalid instruction") }
        
        switch type {
        case .server: listServer()
        case .config: listConfig()
        }
    }
    
    // MARK: - Creat Server
    
    private func creatServer() {
        print("(*) representative must fill in, others can be skipped ; (default: xxx) means it is optional, you can just press enter to skip")
        
        printSplitLine()
        
        guard var config = ServerConfig() else { fatalError("internal error #2") }
        
        print("Server Name(*): ", terminator: "")
        guard let serverName = readLine(), serverName != "" else { fatalError("Unavailable: Server Name") }
        guard checkServerNameRepeat(serverName) else { fatalError("serverName") }
        config.serverName = serverName
        
        print("IP(*): ", terminator: "")
        guard let ip = readLine(), ip != "" else { fatalError("Unavailable: IP") }
        guard checkIP(ip) else { fatalError("The ip adress is wrong") }
        config.ip = ip
        
        print("User Name(*): ", terminator: "")
        guard let userName = readLine(), userName != "" else { fatalError("Unavailable User Name") }
        config.userName = userName
        
        print("Password(*): ", terminator: "")
        guard let password = readLine(), password != "" else { fatalError("Unavailable Password") }
        config.password = password
        
        print("Port(default: 22): ", terminator: "")
        guard let port = Int32(readLine() == "" ? "22" : readLine() ?? "22") else { fatalError("Unavailable Port") }
        config.port = port
        
        printSplitLine()
        
        print("Try to connect...")
        config.system = tryConnect(ip: ip, name: userName, pwd: password, port: port)
        print("=> Your server system is \(config.system.rawValue)")
        
        FileHelper.share.writeServerConfig(config)
        
        printSplitLine()
        
        let pm = PackagesManager(serverName)
        pm.updatePM(false, isCreatServer: true)
        
        printSplitLine()
        
        print("Successfully created")
    }
    
    private func checkServerNameRepeat(_ name: String) -> Bool {
        do {
            let configURLs = try FileHelper.fileManager.contentsOfDirectory(atPath: FileHelper.share.userServerConfigURL.path)
            for path in configURLs {
                guard let url = URL(string: path) else { fatalError("internal error #1") }
                let fileName = (url.path as NSString).deletingPathExtension as String
                if name.trimmingCharacters(in: .whitespaces) == fileName.trimmingCharacters(in: .whitespaces) {
                    return false
                }
            }
            
            return true
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    private func checkIP(_ ip: String) -> Bool {
        let result =  ip !~ #"^((25[0-5]|2[0-4]\d|((1\d{2})|([1-9]?\d)))\.){3}(25[0-5]|2[0-4]\d|((1\d{2})|([1-9]?\d)))$"#
        return !result
    }
    
    private func tryConnect(ip: String, name: String, pwd: String, port: Int32) -> System {
        do {
            let ssh = try SSH(host: ip, port: port)
            try ssh.authenticate(username: name, password: pwd)
            
            let (_, lsbOutput) = try ssh.capture(#"find /etc -name "lsb-release""#)
            if lsbOutput.trimmingCharacters(in: .whitespacesAndNewlines) == "/etc/lsb-release" {
                return .ubuntu
            }
            
            let (_, centosOutput) = try ssh.capture(#"find /etc -name "centos-release""#)
            if centosOutput.trimmingCharacters(in: .whitespacesAndNewlines) == "/etc/centos-release" {
                return .centos
            }
            
            let (_, debianOutput) = try ssh.capture(#"find /etc -name "debian_version""#)
            if debianOutput.trimmingCharacters(in: .whitespacesAndNewlines) == "/etc/debian_version" {
                return .debian
            }
            
            fatalError("Your system is not supported")
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    // MARK: - Creat Config
    
    private func creatConfig() {
        // TODO: Creat config file
    }
    
    // MARK: - List Server
    
    private func listServer() {
        printSplitLine()
        
        do {
            let configURLs = try FileHelper.fileManager.contentsOfDirectory(atPath: FileHelper.share.userServerConfigURL.path)
            let spaces = String(repeating: " ", count: abs(Int(w.ws_col) - 13))
            let title = "Server Name\(spaces)IP"
            print(title)
            
            for path in configURLs {
                guard (path as NSString).pathExtension == "json" else { continue }
                let config = FileHelper.share.getServerConfig((path as NSString).deletingPathExtension)
                guard let name = config.serverName else { fatalError("\(path) is broken") }
                guard let ip = config.ip else { fatalError("\(path) is broken") }
                let sp = String(repeating: " ", count: abs(Int(w.ws_col) - name.count - ip.count))
                print("\(name)\(sp)\(ip)")
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    // MARK: - List Config
    
    private func listConfig() {
        // TODO: List Config
    }
    
    // MARK: - Remove Server
    
    private func removeServer() {
        print("Server Name: ", terminator: "")
        guard let serverName = readLine(), serverName != "" else { fatalError("Server Name is incorrect") }
        print("\u{001B}[0;31m=> You are making a dangerous manoeuvre: deleting your server data\u{001B}[0m")
        print("Continue(Y/\u{001B}[0;32mN\u{001B}[0m): ", terminator: "")
        guard let input = readLine(), input != "" else { fatalError("Input is incorrect") }
        guard input == "Y" else { return }
        guard !checkServerNameRepeat(serverName) else { fatalError("Cannot find the server name") }
        guard mathTest() else {
            print("Calculation error")
            return
        }
        FileHelper.share.removeServerConfig(serverName)
        
        printSplitLine()
        
        print("Done.")
    }
    
    // MARK: - Remove Config
    
    private func removeConfig() {
        // TODO: Remove Config
    }
    
    // MARK: - Edit Server
    
    private func editServer() {
        print("Server Name: ", terminator: "")
        guard let serverName = readLine(), serverName != "" else { fatalError("Server Name is incorrect") }
        print("\u{001B}[0;31m=> You are modifying the Server data\u{001B}[0m")
        print("Continue(Y/\u{001B}[0;32mN\u{001B}[0m): ", terminator: "")
        guard let input = readLine(), input != "" else { fatalError("Input is incorrect") }
        guard input == "Y" else { return }
        
        var config = FileHelper.share.getServerConfig(serverName)
        
        print("User Name(default: \(config.userName!): ", terminator: "")
        guard var newUserName = readLine() else { fatalError("Can't get input") }
        if newUserName == "" { newUserName = config.userName! }
        
        print("Password(default: \(config.password!): ", terminator: "")
        guard var newPwd = readLine() else { fatalError("Can't get input") }
        if newPwd == "" { newPwd = config.password! }
        
        guard mathTest() else {
            print("Calculation error")
            return
        }
        
        config.userName = newUserName
        config.password = newPwd
        
        FileHelper.share.writeServerConfig(config)
    }
    
    // MARK: - Edit Confih
    
    private func editConfig() {
        // TODO: Edit Config
    }
    
    // MARK: - Tool
    
    private func printSplitLine(_ text: String = "=") {
        if ioctl(STDOUT_FILENO, TIOCGWINSZ, &w) == 0 {
            for _ in 0..<w.ws_col { print(text, terminator: "") }
            print("")
        }
    }
    
    func mathTest() -> Bool {
        let num1 = Int.random(in: 1...10000)
        let num2 = Int.random(in: -10000...10000)
        if num2 < 0 {
            print("Real Person Test: \(num1) + (\(num2)) = ", terminator: "")
            guard let input = readLine(), input != "" else { fatalError("Input is incorrect") }
            let result = Int(input)
            return result == num1 + num2
        } else {
            print("Real Person Test: \(num1) + \(num2) = ", terminator: "")
            guard let input = readLine(), input != "" else { fatalError("Input is incorrect") }
            let result = Int(input)
            return result == num1 + num2
        }
    }
}


