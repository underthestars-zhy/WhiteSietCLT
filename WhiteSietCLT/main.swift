//
//  main.swift
//  WhiteSietCLT
//
//  Created by 朱浩宇 on 2021/8/5.
//

import Foundation

guard CommandLine.arguments.count >= 2 else { fatalError("Wrong arguments number") }

guard let command = CommandType(rawValue: CommandLine.arguments[1]) else { fatalError("Cannot Parsing Command") }

switch command {
case .new:
    guard CommandLine.arguments.count == 3 else { fatalError("Wrong arguments number") }
    Manager.share.new(with: CommandLine.arguments[2])
case .remove:
    Manager.share.open()
case .edit:
    Manager.share.edit()
case .open:
    Manager.share.open()
case .list:
    guard CommandLine.arguments.count == 3 else { fatalError("Wrong arguments number") }
    Manager.share.list(for: CommandLine.arguments[2])
}

