//
//  PackagesManager.swift
//  PackagesManager
//
//  Created by 朱浩宇 on 2021/8/8.
//

import Foundation
import Shout

class PackagesManager {
    let serverConfig: ServerConfig
    
    var w = winsize()
    
    init(_ serverName: String) {
        do {
            guard let serverConfig = ServerConfig(JSONString: try String(contentsOf: FileHelper.share.userServerConfigURL.appendingPathComponent(serverName + ".json"))) else { fatalError("Unable to get server information \(serverName)") }
            self.serverConfig = serverConfig
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func updatePM(_ showInfo: Bool, isCreatServer: Bool = false) {
        print("Start update package...")
        let id = ProgressHelper.share.creatProgress { self.printPointProgress($0) }
        
        signal(SIGINT, SIG_IGN)

        let sigintSrc = DispatchSource.makeSignalSource(signal: SIGINT, queue: nil)
        sigintSrc.setEventHandler {
            ProgressHelper.share.stopProgress(id)
            ProgressHelper.share.join(id)
            print("\u{0008} \u{0008}", terminator: "")
            print("\u{0008} \u{0008}", terminator: "")
            if isCreatServer {
                print("Successfully created")
                self.printSplitLine()
                exit(0)
            } else {
                print("Stop update packages")
            }
        }
        sigintSrc.resume()
        
        do {
            let ssh = try SSH(host: serverConfig.ip, port: serverConfig.port)
            try ssh.authenticate(username: serverConfig.userName, password: serverConfig.password)
            
            if serverConfig.system == .centos {
                if showInfo {
                    try ssh.execute("yum -y update")
                } else {
                    (_, _) = try ssh.capture("yum -y update")
                }
            } else {
                if showInfo {
                    try ssh.execute("apt-get update")
                    try ssh.execute("apt-get dist-upgrade -y")
                } else {
                    (_, _) = try ssh.capture("apt-get update")
                    (_, _) = try ssh.capture("apt-get dist-upgrade -y")
                }
            }
        } catch {
            fatalError(error.localizedDescription)
        }
        
        ProgressHelper.share.stopProgress(id)
        ProgressHelper.share.join(id)
    }
    
    // MARK: - Inner Api
    
    func listPlugins() -> [PluginConfig] {
        return []
    }
    
    // MARK: - Tool
    
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
    
    private func printSplitLine(_ text: String = "=") {
        if ioctl(STDOUT_FILENO, TIOCGWINSZ, &w) == 0 {
            for _ in 0..<w.ws_col { print(text, terminator: "") }
            print("")
        }
    }
}
