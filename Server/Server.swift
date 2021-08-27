//
//  Server.swift
//  Server
//
//  Created by Shinichiro Oba on 2021/08/26.
//

import Foundation
import Combine
import Network

class Server: ObservableObject {
    @Published var isConnected = false
    @Published var ipAddress: String?
    
    private var listener: NWListener?
    private var connections: [Connection] = []
    
    func start() {
        guard let listener = try? NWListener(using: .tcp, on: 42001) else { return }
        
        listener.stateUpdateHandler = { [weak self] (newState) in
            DispatchQueue.main.async {
                if newState == .ready {
                    self?.isConnected = true
                    self?.ipAddress = getIpAddresses().first?.value
                    self?.connections = []
                } else {
                    self?.isConnected = false
                    self?.ipAddress = nil
                }
            }
            
            switch newState {
            case .ready:
                print(".ready")
            case .waiting(let error):
                print(".waiting", error)
            case .failed(let error):
                print(".failed", error)
            case .setup:
                print(".setup")
            case .cancelled:
                print(".cancelled")
            @unknown default:
                fatalError()
            }
        }
        
        listener.newConnectionHandler = { [weak self] (connection: NWConnection) in
            print(connection.endpoint)
            print("Connected:", connection, connection.parameters)
            
            let c = Connection(connection: connection)
            let id = c.id
            c.receiveHandler = { [weak c] message in
                print(id, "Received: '\(message)'")
                if message.hasPrefix("peer-name ") {
                    self?.boardcast(message: Message.sendVars.stringData)
                } else {
                    self?.boardcast(message: message, from: c)
                }
            }
            
            c.connect()
            
            self?.connections.append(c)
        }
        
        listener.start(queue: .main)
        
        self.listener = listener
    }
    
    func stop() {
        listener?.cancel()
    }
    
    func boardcast(message: String, from: Connection? = nil) {
        for connection in connections {
            if connection.id != from?.id {
                connection.send(string: message)
            }
        }
    }
}

private func getIpAddresses() -> [String: String] {
    var addresses: [String: String] = [:]
    var ifaddr: UnsafeMutablePointer<ifaddrs>?
    guard getifaddrs(&ifaddr) == 0 else { return [:] }
    guard let firstAddr = ifaddr else { return [:] }
    
    for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
        let interface = ifptr.pointee
        let addrFamily = interface.ifa_addr.pointee.sa_family
        let flags = Int32(interface.ifa_flags)
        if addrFamily == UInt8(AF_INET) /*|| addrFamily == UInt8(AF_INET6)*/ {
            let name = String(cString: interface.ifa_name)
            var addr = interface.ifa_addr.pointee
            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            getnameinfo(&addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                        &hostname, socklen_t(hostname.count),
                        nil, socklen_t(0), NI_NUMERICHOST)
            let host = String(cString: hostname)
            if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING), !host.isEmpty {
                addresses[name] = host
            }
        }
    }
    freeifaddrs(ifaddr)
    
    return addresses
}
