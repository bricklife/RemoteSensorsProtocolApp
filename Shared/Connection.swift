//
//  Connection.swift
//  Shared
//
//  Created by Shinichiro Oba on 2021/08/25.
//

import Foundation
import Combine
import Network

class Connection {
    let id: UUID
    
    @Published var isConnected = false
    var receiveHandler: ((String) -> Void)?
    
    private let connection: NWConnection
    
    init(connection: NWConnection) {
        self.id = UUID()
        self.connection = connection
    }
    
    func connect() {
        connection.stateUpdateHandler = { [weak self] (newState) in
            DispatchQueue.main.async {
                self?.isConnected = (newState == .ready)
            }
            
            switch newState {
            case .ready:
                print(".ready")
                self?.receiveHeader()
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
        
        connection.start(queue: DispatchQueue(label: "com.bricklife.RemoteSensorsProtocolApp.Connection"))
    }
    
    func disconnect() {
        connection.cancel()
    }
    
    private func receiveHeader() {
        connection.receive(minimumIncompleteLength: 4, maximumLength: 4, completion: { [weak self] data, context, completed, error in
            if let error = error {
                print("Receive Error: \(error)")
                self?.disconnect()
                return
            }
            
            guard let data = data, data.count == 4 else {
                print("Receive Error: data is invalid")
                self?.disconnect()
                return
            }
            
            let length = UInt32(bigEndian: data.withUnsafeBytes { $0.load(as: UInt32.self) })
            self?.receiveBody(length: Int(length))
        })
    }
    
    private func receiveBody(length: Int) {
        guard length > 0 else {
            receiveHeader()
            return
        }
        
        connection.receive(minimumIncompleteLength: length, maximumLength: length, completion: { [weak self] data, context, completed, error in
            if let error = error {
                print("Receive Error: \(error)")
                self?.disconnect()
                return
            }
            
            guard let data = data, data.count == length, let body = String(data: data, encoding: .utf8) else {
                print("Receive Error: data is invalid")
                self?.disconnect()
                return
            }
            
            DispatchQueue.main.async {
                self?.receiveHandler?(body)
            }
            
            self?.receiveHeader()
        })
    }
    
    func send(message: Message) {
        send(string: message.stringData)
    }
    
    func send(string: String) {
        guard isConnected else { return }
        guard let body = string.data(using: .utf8), body.count <= UInt32.max else { return }
        
        let length = UInt32(body.count)
        var data = withUnsafeBytes(of: length.bigEndian) { Data($0) }
        data.append(body)
        
        let id = id
        connection.send(content: data, completion: .contentProcessed({ error in
            if let error = error {
                print(id, "Send Error: \(error)")
                return
            }
            print(id, "Sent: '\(string)'")
        }))
    }
}
