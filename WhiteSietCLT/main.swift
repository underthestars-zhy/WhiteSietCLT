//
//  main.swift
//  WhiteSietCLT
//
//  Created by 朱浩宇 on 2021/8/5.
//

import Foundation

guard let argu = CommandLine.arguments.first, let command = CommandType(rawValue: argu) else { fatalError("Cannot Parsing Command") }

switch command {
case .new:
    guard CommandLine.arguments.count == 2 else { fatalError("Wrong arguments number") }
    Manager.share.new(with: CommandLine.arguments[1])
case .remove:
    Manager.share.open()
case .edit:
    Manager.share.edit()
case .open:
    Manager.share.open()
}
