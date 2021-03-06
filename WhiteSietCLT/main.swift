//
//  main.swift
//  WhiteSietCLT
//
//  Created by 朱浩宇 on 2021/8/5.
//

import Foundation

guard CommandLine.arguments.count == 3 else { fatalError("Wrong arguments number") }

guard let command = CommandType(rawValue: CommandLine.arguments[1]) else { fatalError("Cannot Parsing Command") }

switch command {
case .new:
    Manager.share.new(with: CommandLine.arguments[2])
case .remove:
    Manager.share.remove(with: CommandLine.arguments[2])
case .edit:
    Manager.share.edit(with: CommandLine.arguments[2])
case .open:
    Manager.share.open(with: CommandLine.arguments[2])
case .list:
    Manager.share.list(for: CommandLine.arguments[2])
}

