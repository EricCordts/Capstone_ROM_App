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

let start = CFAbsoluteTimeGetCurrent()
let file = "Identifiers.txt"

typealias Finished = () -> ()

class BluetoothViewController: UIViewController, CBCentralManagerDelegate, ObservableObject, CBPeripheralDelegate {
    
    /* Variables */
    @Published var isSwitchedOn = false
    @Published var characteristicInfo: [CBCharacteristic] = []
    @Published var soughtPeripherals: [String:CBPeripheral] = [:]
    @Published var isConnected: [String:Bool] = [:]
    var centralManager: CBCentralManager!
    var discoveredPeripherals: [String:CBPeripheral] = [:]
    var arduinoServices = [
        // UUID's of Arduino Services you are scanning for
        CBUUID.init(string: "2a675dfb-a1b0-4c11-9ad1-031a84594196")
    ]
    
    var modelController: ModelController!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.isConnected = modelController.isConnected
    }
    
    /* Init */
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        centralManager.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /* Delegate Functions */
    
    // centralManagerDidDiscover
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        self.discoveredPeripherals[peripheral.identifier.uuidString] = peripheral
   
        print(peripheral.identifier.uuidString) // TODO: Figure out why this prints twice for each arduino.
        // Use name as unique identifier
        switch peripheral.identifier.uuidString {
        case "2D7F82BF-7F7F-F332-EC3E-EC75941F228F":
            self.connect(peripheral: peripheral)
        case "71CBE43D-63A4-8FA2-CA20-BB87A5438CA7":
            self.connect(peripheral: peripheral)
            break
        default:
            break
        }
    }

    //  centralManagerDidConnect
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // Successfully connected. Store reference to peripheral if not already done.
        self.soughtPeripherals[peripheral.identifier.uuidString] = peripheral
        peripheral.delegate = self
        modelController.isConnected[peripheral.identifier.uuidString] = true
        self.discoverServices(peripheral: peripheral)
    }
    
    // centralManagerDidFailToConnect
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if let error = error {
            print("ERROR didFailToConnect message: \(error)")
            modelController.isConnected[peripheral.identifier.uuidString] = false
            self.centralManagerDidUpdateState(central) // Called to trigger update of BluetoothView in ContentView
            return
        }
    }
    
    // centralManagerDidDisconnectPeripheral
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let error = error {
            print("ERROR didDisconnectPeripheral message: \(error)")
            modelController.isConnected[peripheral.identifier.uuidString] = false
            self.soughtPeripherals.removeValue(forKey: peripheral.identifier.uuidString)
            self.centralManagerDidUpdateState(central) // Called to trigger update of BluetoothView in ContentView
            return
        }
        self.centralManager.connect(peripheral, options: nil)
    }
    
    // peripheralDidDiscoverServices
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("ERROR didDiscoverServices message: \(error)")
            return
        }
        self.discoverCharacteristics(peripheral: peripheral)
    }
    
    // peripheralDidDiscoverCharacteristicsFor
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("ERROR didDiscoverCharacteristicsFor message: \(error)")
            return
        }
        guard let characteristics = service.characteristics else {
            return
        }
        // Consider storing important characteristics internally for easy access and equivalency checks later.
        // From here, can read/write to characteristics or subscribe to notifications as desired.
        characteristicInfo.append(contentsOf: characteristics)
        for characteristic in characteristicInfo {
            peripheral.readValue(for: characteristic)
        }
    }
    
    // peripheralDidUpdateNotifiationStateFor
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("ERROR didUpdateNotificationStateFor message: \(error)")
            return
        }
        // Update state of BluetoothView
        self.centralManagerDidUpdateState(centralManager)
    }
    
    // peripheralDidUpdateValueFor
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("ERROR didUpdateValue message:\(error)")
            return
        }
        
        if let data = characteristic.value {
            var myArray16 = Array<Int16>(repeating: 0, count:data.count/MemoryLayout<Int16>.stride)
            myArray16.withUnsafeMutableBytes { data.copyBytes(to: $0) }
            handleByteBuffer(peripheral: peripheral, characteristic: characteristic, buffer: myArray16, start: CFAbsoluteTimeGetCurrent())
        }
    }
    
    
    // Process the Position Data that has been updated
    func handleByteBuffer(peripheral: CBPeripheral, characteristic: CBCharacteristic, buffer: [Int16], start: CFAbsoluteTime) {
        let today = Date()
        let hours   = (Calendar.current.component(.hour, from: today))
        let minutes = (Calendar.current.component(.minute, from: today))
        let seconds = (Calendar.current.component(.second, from: today))
        print("\(hours):\(minutes):\(seconds) ---> bytes: \(buffer) \(peripheral.identifier)")
        peripheral.readValue(for: characteristic)
    }
    
    
    /* Helper Functions */
    
    // Start Scanning for peripherals
    func startScan() {
        centralManager.scanForPeripherals(withServices: arduinoServices, options: nil)
    }
    
    // centralManagerDidUpdateState
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // possible states of Core Bluetooth as of iOS 10 including default case
        switch central.state {
            case .poweredOn:
                isSwitchedOn = true
                startScan()
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
    
    // Connect to a peripheral
    func connect(peripheral: CBPeripheral) {
        centralManager.connect(peripheral, options: nil)
     }
    
    // Discover the services of a peripheral
    func discoverServices(peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
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
    
    func handleError(name: String, error: Error?) -> Bool {
        // TODO: Finish Function
        if let error = error {
            print("ERROR  message:\(error)")
            return false
        }
        return true
    }
    
    
    /* --- UNUSED FUNCTIONS --- */
    // Disconnect from a peripheral
    func disconnect(peripheral: CBPeripheral) {
        centralManager.cancelPeripheralConnection(peripheral)
    }
}
