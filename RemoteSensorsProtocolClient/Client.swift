//
//  Client.swift
//  RemoteSensorsProtocolClient
//
//  Created by Shinichiro Oba on 2021/08/23.
//

import Foundation
import Combine
import Network

class Client: ObservableObject {
    
    var connection: Connection?
    
    @Published var isConnected = false
    
    func connect(host: String) {
        let host = NWEndpoint.Host(host)
        let port = NWEndpoint.Port(integerLiteral: 42001)
        
        let connection = Connection(connection: NWConnection(host: host, port: port, using: .tcp))
        
        connection.$isConnected.assign(to: &$isConnected)
        connection.receiveHandler = { message in
            print("Received: '\(message)'")
        }
        
        connection.connect()
        
        self.connection = connection
    }
    
    func disconnect() {
        connection?.disconnect()
    }
    
    func send(_ message: Message) {
        connection?.send(message: message)
    }
    
    func send(_ string: String) {
        connection?.send(string: string)
    }
}
