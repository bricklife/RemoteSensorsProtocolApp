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
    
    @Published var isConnected = false
    @Published var host: String?
    
    private var connection: NWConnection?
    
    func connect(host: String) {
        let host = NWEndpoint.Host(host)
        let port = NWEndpoint.Port(integerLiteral: 42001)
        
        let connection = NWConnection(host: host, port: port, using: .tcp)
        
        connection.stateUpdateHandler = { [weak self] (newState) in
            self?.isConnected = (newState == .ready)
            switch newState {
            case .ready:
                print(".ready")
                self?.receive()
            case .waiting(let error):
                print(".waiting", error)
            case .failed(let error):
                print(".failed", error)
            case .setup:
                print(".setup")
            case .cancelled:
                print(".cancelled")
            case .preparing:
                print(".preparing")
            @unknown default:
                fatalError()
            }
        }
        
        connection.start(queue: .main)
        
        self.connection = connection
    }
    
    func disconnect() {
        connection?.cancel()
    }
    
    private func receive() {
        connection?.receive(minimumIncompleteLength: 0, maximumLength: 1000, completion: { [weak self] data, context, completed, error in
            if let error = error {
                print("Receive Error: \(error)")
                self?.disconnect()
                return
            }
            
            if let data = data, data.count >= 4 {
                let len = Int(data[3]) // TODO: Use all 4 bytes
                let body = data.dropFirst(4).prefix(len)
                if let s = String(data: body, encoding: .utf8) {
                    print("Received: [\(len)] '\(s)'")
                }
            }
            
            self?.receive()
        })
    }
    
    func send(_ s: String) {
        guard isConnected else { return }
        guard let body = s.data(using: .utf8) else { return }
        let len = UInt8(body.count)
        var data = Data([0, 0, 0, len]) // TODO: Use all 4 bytes
        data.append(body)
        
        connection?.send(content: data, completion: .contentProcessed({ error in
            if let error = error {
                print("Send Error: \(error)")
                return
            }
            print("Sent: [\(len)] '\(s)'")
        }))
    }
}
