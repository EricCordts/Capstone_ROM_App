//
//  ContentView.swift
//  Shared
//
//  Created by Colin Regan on 1/20/22.
//

import SwiftUI
import CoreBluetooth
import UIKit

struct ContentView: View {
    @ObservedObject var bleManager = BluetoothViewController()

    init() {
        UITableView.appearance().backgroundColor = UIColor.clear
        UITableViewCell.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        NavigationView{
            OpeningPage()
            .navigationBarHidden(true);
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct BluetoothView : View {
    @ObservedObject var bleManager = BluetoothViewController()
    var body : some View {
        if bleManager.isSwitchedOn {
            Text("Bluetooth is switched on")
                .foregroundColor(.green)
            if bleManager.isConnected {
                Text("Connected to yo mama")
                    .foregroundColor(.green)
                if !bleManager.characteristicInfo.isEmpty && bleManager.characteristicInfo[0].isNotifying {
                    Text("notifying")
                        .foregroundColor(.green)
                } else {
                    Text("not notifying")
                        .foregroundColor(.red)
                }
            }
            Text("\(bleManager.Xvalue) : \(bleManager.Yvalue) : \(bleManager.Zvalue)")
                .foregroundColor(.blue)
        } else {
            Text("Bluetooth is NOT switched on")
                .foregroundColor(.red)
        }
        
    }
}
