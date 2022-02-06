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

class BluetoothViewController: UIViewController, CBCentralManagerDelegate, ObservableObject, CBPeripheralDelegate {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        centralManager.delegate = self

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /* --- VARIABLES --- */
    @Published var isSwitchedOn = false
    @Published var isConnected = false
    var centralManager: CBCentralManager!
    var discoveredPeripherals = [CBPeripheral]()
    var uuids: [CBService] = []
    var connected = false
    var arduinos = [
        CBUUID.init(string: "2a675dfb-a1b0-4c11-9ad1-031a84594196"),
        CBUUID.init(string: "2ba18a92-0427-4579-9884-a3c8e53dad59")
    ]
    var connectedPeripheral: CBPeripheral?
    var characteristicInfo: [CBCharacteristic] = []
    var peripheralZero : CBPeripheral!
    var serviceZero : [ CBService ] = []
    
    /* --- DELEGATE EXTENSION --- */
    
    // Peripheral Discovered
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        self.discoveredPeripherals.append(peripheral)
        switch peripheral.name {
            case "yo mama":
                peripheralZero  = peripheral
                connect(peripheral: peripheral)
                centralManager(central, didConnect: peripheral)
            case "yo papa":
                break
            case .none:
                break
            case .some(_):
                break
        }
    }

    // Peripheral Successfully Connects
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // Successfully connected. Store reference to peripheral if not already done.
        self.connectedPeripheral = peripheral
        peripheral.delegate = self
        self.connected = true
        isConnected = true
        discoverServices(peripheral: peripheral)
    }
    
    // Peripheral Failed to Connect
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        // Handle error
    }
    
    // Peripheral Disconnects
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let error = error {
            // Handle error
            self.connected = false
            isConnected = false
            self.centralManagerDidUpdateState(central) // Called to trigger update of BluetoothView in ContentView
            return
        }
        // Successfully disconnected
    }
    
    // Discovered a Service
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            return
        }
        discoverCharacteristics(peripheral: peripheral)
    }
    
    // Discovered a Characteristic
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            return
        }
        // Consider storing important characteristics internally for easy access and equivalency checks later.
        // From here, can read/write to characteristics or subscribe to notifications as desired.
        characteristicInfo.append(contentsOf: characteristics)
    }
    
    /* --- FUNCTIONS --- */
    
    // Start Scanning for peripherals
    func startScan() {
        centralManager.scanForPeripherals(withServices: arduinos, options: nil)
    }
    
    // Handle State Updates of Central Manager
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // possible states of Core Bluetooth as of iOS 10 including default case
        switch central.state {
            case .poweredOn:
                isSwitchedOn = true
                startScan()
            case .poweredOff:
                isSwitchedOn = false
                isConnected = false
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
    
    // Connect to a peripheral
    func connect(peripheral: CBPeripheral) {
        centralManager.connect(peripheral, options: nil)
     }
    
    // Disconnect from a peripheral
    func disconnect(peripheral: CBPeripheral) {
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
    // Discover the services of a peripheral
    func discoverServices(peripheral: CBPeripheral) {
        peripheral.discoverServices([CBUUID.init(string: "2ba18a92-0427-4579-9884-a3c8e53dad59")])
    }
     
    // Discover the characteristics of each service in a peripheral
    func discoverCharacteristics(peripheral: CBPeripheral) {
        guard let services = peripheral.services else {
            return
        }
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    /* --- OVERRIDDEN FUNCTIONS --- */
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}


