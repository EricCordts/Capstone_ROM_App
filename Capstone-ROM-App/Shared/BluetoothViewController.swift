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
    public var discoveredPeripherals = [CBPeripheral]()
    var uuids: [CBService] = []
    var arduinos = [
        CBUUID.init(string: "2a675dfb-a1b0-4c11-9ad1-031a84594196"),
        CBUUID.init(string: "2ba18a92-0427-4579-9884-a3c8e53dad59")
    ]
    var characteristics = [
        CBUUID.init(string: "d81c825a-4849-4606-9b43-54214c5cd8cd"),
        CBUUID.init(string: "f86a30d0-3af0-413f-a21b-26a2ab665933"),
        CBUUID.init(string: "7f15286c-ac14-47e7-ac68-26151a6a9e6f")
    ]
    var connectedPeripheral: CBPeripheral?
    @Published var characteristicInfo: [CBCharacteristic] = []
    public var strong_reference: [CBPeripheral] = [CBPeripheral]()
    var peripheralZero : CBPeripheral!
    var serviceZero : [ CBService ] = []
    
    /* --- DELEGATE EXTENSION --- */
    
    // Peripheral Discovered
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        self.discoveredPeripherals.append(peripheral)
        switch peripheral.name {
            case "yo mama":
                strong_reference.append(peripheral)
                connect(peripheral: strong_reference[0])
                //centralManager(central, didConnect: discoveredPeripherals[0])
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
        //self.strong_reference.append(peripheral)
        peripheral.delegate = self
       
        isConnected = true
        
        peripheral.discoverServices([CBUUID.init(string: "2a675dfb-a1b0-4c11-9ad1-031a84594196")])
    }
    
    // Peripheral Failed to Connect
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        // Handle error
    }
    
    // Peripheral Disconnects
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let error = error {
                print("ERROR didDisconnectPeripheral \(error)")
                isConnected = false
                self.centralManagerDidUpdateState(central) // Called to trigger update of BluetoothView in ContentView
                return
        }
        
        // Successfully disconnected
        self.centralManager.connect(peripheral, options: nil)
    }
    
    // Discovered a Service
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            return
        }
        for service in services {
            peripheral.discoverCharacteristics(characteristics, for: service)
        }
    }
    
    // Discovered a Characteristic
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            return
        }
        // Consider storing important characteristics internally for easy access and equivalency checks later.
        // From here, can read/write to characteristics or subscribe to notifications as desired.
        characteristicInfo.append(contentsOf: characteristics)
        for characteristic in characteristicInfo {
            peripheral.setNotifyValue(true, for: characteristic)
            peripheral.readValue(for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
                print("ERROR didUpdateNotificationStateFor \(error)")
                return
        }
        self.centralManagerDidUpdateState(centralManager) 
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
                print("ERROR didUpdateValue \(error)")
                return
        }
        
        var wavelength: UInt16?
        if let unwrapped = characteristic.value {
            var bytes = Array(repeating: 0 as UInt8, count:unwrapped.count/MemoryLayout<UInt8>.size)

            unwrapped.copyBytes(to: &bytes, count:unwrapped.count)
            let data16 = bytes.map { UInt16($0) }
            wavelength = 256 * data16[1] + data16[0]
        }

        print("\(characteristic.uuid) \(wavelength)")
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
        //peripheral.discoverServices([CBUUID.init(string: "2a675dfb-a1b0-4c11-9ad1-031a84594196")])
        peripheral.discoverServices([CBUUID.init(string: "2a675dfb-a1b0-4c11-9ad1-031a84594196")])
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

extension Data {
    var uint32: UInt32 {
            get {
                let i32array = self.withUnsafeBytes { $0.load(as: UInt32.self) }
                return i32array
            }
        }
}
