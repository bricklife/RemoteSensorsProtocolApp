//
//  ContentView.swift
//  Client
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
                        if !broadcast.isEmpty {
                            client.send(.broadcast(broadcast))
                        } else {
                            print("The message is empty")
                        }
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
                        if !stringName.isEmpty {
                            let v = Variable(name: stringName, value: .string(stringValue))
                            client.send(.sensorUpdate([v]))
                        } else {
                            print("The name is empty")
                        }
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
                        if let value = Decimal(string: numberValue) {
                            let v = Variable(name: numberName, value: .number(value))
                            client.send(.sensorUpdate([v]))
                        } else {
                            print("\"\(numberValue)\" is not a number")
                        }
                    }
                }
            }
            
            Section(header: Text("Send Any Message")) {
                HStack {
                    TextField("e.g. send-vars, peer-name anonymous, etc.", text: $message)
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
