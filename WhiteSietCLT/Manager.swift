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

class Manager {
    static let share = Manager()
    
    var w = winsize()
    
    init() {
        
    }
    
    // MARK: - Instruction processing
    
    func new(with argument: String) {
        guard let type = NewType(rawValue: argument) else { fatalError("Invalid instruction") }
        
        switch type {
        case .server: creatServer()
        case .config: creatConfig()
        }
    }
    
    func remove() {
        
    }
    
    func edit() {
        
    }
    
    func `open`() {
        
    }
    
    func list(for argument: String) {
        guard let type = NewType(rawValue: argument) else { fatalError("Invalid instruction") }
        
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
        
        print("Start update package...")
        let id = ProgressHelper.share.creatProgress { self.printPointProgress($0) }
        self.updatePM(ip: ip, name: userName, pwd: password, port: port, system: config.system)
        ProgressHelper.share.stopProgress(id)
        ProgressHelper.share.join(id)
        
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
                    print(url.pathExtension.trimmingCharacters(in: .whitespaces))
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
    
    func creatConfig() {
        // TODO: Creat config file
    }
    
    // MARK: - List Server
    
    func listServer() {
        printSplitLine()
        
        do {
            let configURLs = try FileHelper.fileManager.contentsOfDirectory(atPath: FileHelper.share.userServerConfigURL.path)
            let spaces = String(repeating: " ", count: abs(Int(w.ws_col) - 13))
            let title = "Server Name\(spaces)IP"
            print(title)
            
            for path in configURLs {
                guard (path as NSString).pathExtension == "json" else { continue }
                guard let config = ServerConfig(JSONString: try String(contentsOf: FileHelper.share.userServerConfigURL.appendingPathComponent(path))) else { fatalError("\(path) is broken") }
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
    
    func listConfig() {
        // TODO: List Config
    }
    
    // MARK: - Tool
    
    private func printSplitLine(_ text: String = "=") {
        if ioctl(STDOUT_FILENO, TIOCGWINSZ, &w) == 0 {
            for _ in 0..<w.ws_col { print(text, terminator: "") }
            print("")
        }
    }
    
    private func printPointProgress(_ id: UUID) {
        while ProgressHelper.share.state(id) {
            ProgressHelper.share.wait(id)
            sleep(1)
            print(".", terminator: "")
            fflush(stdout)
            sleep(1)
            print("\u{0008} \u{0008}", terminator: "")
            fflush(stdout)
            ProgressHelper.share.stopWait(id)
        }
    }
    
    // MARK: - PM
    
    private func updatePM(ip: String, name: String, pwd: String, port: Int32, system: System) {
        do {
            let ssh = try SSH(host: ip, port: port)
            try ssh.authenticate(username: name, password: pwd)
            
            if system == .centos {
                (_, _) = try ssh.capture("yum -y update")
            } else {
                (_, _) = try ssh.capture("apt-get update")
                (_, _) = try ssh.capture("apt-get dist-upgrade -y")
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}


