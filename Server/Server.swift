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
    
    func start() {
        isConnected = true
        ipAddress = getIpAddresses().first?.value
    }
    
    func stop() {
        isConnected = false
        ipAddress = nil
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
