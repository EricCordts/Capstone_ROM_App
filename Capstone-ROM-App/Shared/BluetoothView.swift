//
//  BluetoothView.swift
//  Capstone-ROM-App (iOS)
//
//  Created by Colin Regan on 3/7/22.
//

import Foundation
import CoreBluetooth
import SwiftUI

struct BluetoothView : View {
    @StateObject var bleManager = BluetoothViewController()
    var modelController: ModelController!
    
    var body : some View {
        if bleManager.isSwitchedOn {
            Text("Bluetooth is switched on")
                .foregroundColor(.black)
            VStack{
                ForEach(bleManager.soughtPeripherals.map{$0.key}.indices, id: \.self) { index in
                    let peripheral = bleManager.soughtPeripherals.map{$0.value}[index]
                        if peripheral.state == CBPeripheralState.init(rawValue: 2){
                        Text("Connected to \( peripheral.name ?? "Arbitrary Arduino ") ")
                            .foregroundColor(.black)
                    }
                }
            }
        } else {
            Text("Bluetooth is NOT switched on")
                .foregroundColor(.red)
        }
    }
}
