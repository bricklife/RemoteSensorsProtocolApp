//
//  ContentView.swift
//  RemoteSensorsProtocolClient
//
//  Created by Shinichiro Oba on 2021/08/23.
//

import SwiftUI

struct ContentView: View {
    
    @AppStorage("host") private var host = "localhost"
    
    @AppStorage("broadcast") private var broadcast = "message"
    
    @AppStorage("stringName") private var stringName = "string"
    @AppStorage("stringValue") private var stringValue = "ABC"
    
    @AppStorage("numberName") private var numberName = "number"
    @AppStorage("numberValue") private var numberValue = "123"
    
    @AppStorage("message") private var message = "send-vars"
    
    @StateObject private var client = Client()
    
    var body: some View {
        Form {
            Section(header: Text("Host")) {
                HStack {
                    TextField("localhost", text: $host)
                        .border(Color.gray, width: 1)
                        .disabled(client.isConnected)
                    Text(": 42001")
                }
                HStack {
                    if client.isConnected {
                        Text("Connected")
                    } else {
                        Text("Not connected")
                    }
                    Spacer()
                    if client.isConnected {
                        Button("Disconnect") {
                            client.disconnect()
                        }
                    } else {
                        Button("Connect") {
                            client.connect(host: host)
                        }
                    }
                }
            }
            
            Section(header: Text("Broadcast")) {
                HStack {
                    TextField("Message String", text: $broadcast)
                        .border(Color.gray, width: 1)
                    Button("Send") {
                        client.send("broadcast \"\(broadcast)\"")
                    }
                }
            }
            
            Section(header: Text("Sensor Update (String)")) {
                HStack {
                    TextField("Variable Name", text: $stringName)
                        .border(Color.gray, width: 1)
                    TextField("ABC", text: $stringValue)
                        .border(Color.gray, width: 1)
                    Button("Send") {
                        client.send("sensor-update \"\(stringName)\" \"\(stringValue)\"")
                    }
                }
            }
            
            Section(header: Text("Sensor Update (Number)")) {
                HStack {
                    TextField("Variable Name", text: $numberName)
                        .border(Color.gray, width: 1)
                    TextField("123", text: $numberValue)
                        .border(Color.gray, width: 1)
                        .keyboardType(.numberPad)
                    Button("Send") {
                        if let value = Int(numberValue) {
                            client.send("sensor-update \"\(numberName)\" \(value)")
                        } else {
                            print("\"\(numberValue)\" is not a number")
                        }
                    }
                }
            }
            
            Section(header: Text("Send Any Message")) {
                HStack {
                    TextField("send-vars", text: $message)
                        .border(Color.gray, width: 1)
                    Button("Send") {
                        client.send(message)
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
