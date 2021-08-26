//
//  Message.swift
//  Shared
//
//  Created by Shinichiro Oba on 2021/08/25.
//

import Foundation

enum Message {
    case broadcast(String)
    case sensorUpdate([Variable])
    case peerName
    case sendVars
    
    var stringData: String {
        switch self {
        case .broadcast(let message):
            return "broadcast \(message.quoted)"
        case .sensorUpdate(let variables):
            let body = variables.map { $0.stringData }.joined(separator: " ")
            return "sensor-update \(body)"
        case .peerName:
            return "peer-name anonymous"
        case .sendVars:
            return "send-vars"
        }
    }
}

struct Variable {
    let name: String
    let value: Value
    
    enum Value {
        case string(String)
        case number(Decimal)
        
        var stringData: String {
            switch self {
            case .string(let value):
                return value.quoted
            case .number(let value):
                return value.description
            }
        }
    }
    
    var stringData: String {
        return "\(name.quoted) \(value.stringData)"
    }
}

private extension String {
    var quoted: String {
        return "\"\(self.replacingOccurrences(of: "\"", with: "\"\""))\""
    }
}
