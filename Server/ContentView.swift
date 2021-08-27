//
//  ContentView.swift
//  Server
//
//  Created by Shinichiro Oba on 2021/08/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var server = Server()
    
    var body: some View {
        Form {
            Section {
                HStack {
                    if server.isConnected {
                        Text("Started - \(server.ipAddress ?? "")")
                    } else {
                        Text("Not started")
                    }
                    Spacer()
                    if server.isConnected {
                        Button("Stop") {
                            server.stop()
                        }
                    } else {
                        Button("Start") {
                            server.start()
                        }
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
