//
//  BluetoothViewController.swift
//  Capstone-ROM-App
//
//  Created by Colin Regan on 2/1/22.
//

import Foundation
import UIKit
import CoreBluetooth
import SwiftUI

class BluetoothViewController: UIViewController, CBCentralManagerDelegate, ObservableObject {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        centralManager.delegate = self
        //arduinos.append(CBUUID.init(string: "180A"))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // VARIABLES
    // ---------
    
    @Published var isSwitchedOn = false
    var centralManager: CBCentralManager!
    var discoveredPeripherals = [CBPeripheral]()
    var arduinos: [CBUUID] = []
    let test = CBUUID().uuidString.lowercased()
    

    // DELEGATE EXTENSION
    // ------------------
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        self.discoveredPeripherals.append(peripheral)
    }
    
    // FUNCTIONS
    // ---------
    // startScan - initiates peripheral device scanning from the iPhone if bluetooth is enabled
    // ...
    func startScan() {
        centralManager.scanForPeripherals(withServices: arduinos, options: nil)
    }
    // centralManagerDidUpdateState - Called by Core Bluetooth when the state of bluetooth on the phona and in the app is changed
    // 1. _ central: CBCentral Manager - Core Bluetooth central manager for all BLE interactions
    // ...
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // possible states of Core Bluetooth as of iOS 10 including default case
        switch central.state {
            case .poweredOn:
                isSwitchedOn = true
                //startScan()
            case .poweredOff:
                isSwitchedOn = false
                // Alert user to turn on Bluetooh
            case .resetting:
                break
                // Wait for next state update and consider logging interuption of Bluetooth service
            case .unauthorized:
                break
                // Alert user to enable Bluetooth permission in app Settings
            case .unsupported:
                break
                // Alert user their device does not support Bluetooth and app will not work as expected
            case .unknown:
                break
                // Wait for next state update
            @unknown default:
                break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    
    
}


