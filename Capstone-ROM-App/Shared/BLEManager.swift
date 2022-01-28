//
//  BLEManager.swift
//  Capstone-ROM-App
//
//  Created by Colin Regan on 1/27/22.
//

import Foundation
import CoreBluetooth

// Central Manager for BLE Framework
class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate {
    var myCentral: CBCentralManager!
    // Monitor if BLE is active(on)  on the iPhone
    var isSwitchedOn = false // TODO: Add @Published if we want this to automatically Refresh in the UI in ContentView

    // Override initiation function to initialize myCentral
    override init() {
        super.init()
        
        myCentral = CBCentralManager(delegate: self, queue: nil)
        // Make itself the delegate to call delegate methods.
        myCentral.delegate = self
    }
    
    // Required function stub for CBCentralManagerDelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            isSwitchedOn = true
        } else {
            isSwitchedOn = false
        }
    }
}
