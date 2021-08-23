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
    
    
    @State private var isConnected = false
    
    var body: some View {
        Form {
            Section(header: Text("Host")) {
                HStack {
                    TextField("localhost", text: $host)
                        .border(Color.gray, width: 1)
                        .disabled(isConnected)
                    Text(": 42001")
                }
                HStack {
                    if isConnected {
                        Text("Connected")
                    } else {
                        Text("Not connected")
                    }
                    Spacer()
                    if isConnected {
                        Button("Disconnect") {
                            isConnected = false
                        }
                    } else {
                        Button("Connect") {
                            isConnected = true
                        }
                    }
                }
            }
            
            Section(header: Text("Broadcast")) {
                HStack {
                    TextField("Message String", text: $broadcast)
                        .border(Color.gray, width: 1)
                    Button("Send") {
                        print("broadcast \"\(broadcast)\"")
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
                        print("sensor-update \"\(stringName)\" \"\(stringValue)\"")
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
                            print("sensor-update \"\(numberName)\" \(value)")
                        } else {
                            print("\"\(numberValue)\" is not a number")
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
