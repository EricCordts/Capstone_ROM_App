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

typealias Finished = () -> ()

class BluetoothViewController: UIViewController, CBCentralManagerDelegate, ObservableObject, CBPeripheralDelegate {
    
    /* --- REQUIRED INITIALIZATION --- */
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        centralManager.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /* --- VARIABLES --- */
    // Published variables go here. These variables automatically announce when they've been changed. (reinvoked 'body' property)
    @Published var isSwitchedOn = false
    @Published var isConnected: [String:Bool] = [:]
    @Published var characteristicInfo: [CBCharacteristic] = []
    @Published var soughtPeripherals: [String:CBPeripheral] = [:]  // explicit strong reference containing list of desired peripherals
    @Published var accelValues: [String:accelerometerData] = [:]

    // Normal Variables
    var centralManager: CBCentralManager!
    var discoveredPeripherals: [String:CBPeripheral] = [:]
    var arduinos = [
        // UUID's of Arduino Services you are scanning for
        CBUUID.init(string: "2a675dfb-a1b0-4c11-9ad1-031a84594196"),
        CBUUID.init(string: "fc6e77ae-713d-47b0-ab7a-88340d3b1986")
    ]
    
    /* --- DELEGATE EXTENSION --- */
    
    // Peripheral Discovered
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        self.discoveredPeripherals[peripheral.identifier.uuidString] = peripheral
        
        print(peripheral.identifier.uuidString)
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

    // Peripheral Successfully Connects
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // Successfully connected. Store reference to peripheral if not already done.
        self.soughtPeripherals[peripheral.identifier.uuidString] = peripheral
        self.accelValues[peripheral.identifier.uuidString] = accelerometerData.init()
        peripheral.delegate = self
        isConnected[peripheral.identifier.uuidString] = true
        self.discoverServices(peripheral: peripheral)
    }
    
    // Peripheral Failed to Connect
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if let error = error {
            print("ERROR didFailToConnect message: \(error)")
            isConnected[peripheral.identifier.uuidString] = false
            self.centralManagerDidUpdateState(central) // Called to trigger update of BluetoothView in ContentView
            return
        }
    }
    
    // Peripheral Disconnects
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let error = error {
            print("ERROR didDisconnectPeripheral message: \(error)")
            isConnected[peripheral.identifier.uuidString] = false
            self.soughtPeripherals.removeValue(forKey: peripheral.identifier.uuidString)
            self.centralManagerDidUpdateState(central) // Called to trigger update of BluetoothView in ContentView
            return
        }
        
        // Successfully disconnected
        self.centralManager.connect(peripheral, options: nil)
    }
    
    // Discovered a Service
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("ERROR didDiscoverServices message: \(error)")
            return
        }
        self.discoverCharacteristics(peripheral: peripheral)
    }
    
    // Discovered a Characteristic
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
            peripheral.setNotifyValue(true, for: characteristic)
            peripheral.readValue(for: characteristic)
        }
    }
    
    // Callback: Updated the notification state of a characteristic
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("ERROR didUpdateNotificationStateFor message: \(error)")
            return
        }
        // Update state of BluetoothView
        self.centralManagerDidUpdateState(centralManager) 
    }
    
    // Callback: Updated the value held by a characteristics
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {

        if let error = error {
            print("ERROR didUpdateValue message:\(error)")
            return
        }
        
        // Convert Data? object into readable format
        var wavelength: UInt16?
        if let unwrapped = characteristic.value {
            var bytes = Array(repeating: 0 as UInt8, count:unwrapped.count/MemoryLayout<UInt8>.size)

            unwrapped.copyBytes(to: &bytes, count:unwrapped.count)
            let data16 = bytes.map { UInt16($0) }
            wavelength = 256 * data16[1] + data16[0]
        }
        
        if let wavelength = wavelength {
            processXyz(peripheral: peripheral, uuid: characteristic.uuid, value: wavelength, start: start)
        }
    }
    
    
    // Process the Position Data that has been updated.
    func processXyz(peripheral: CBPeripheral, uuid: CBUUID, value: UInt16, start: CFAbsoluteTime) {

        
        switch peripheral.identifier.uuidString {
        case "2D7F82BF-7F7F-F332-EC3E-EC75941F228F":
                switch uuid.uuidString {
                case "2101":
                    accelValues[peripheral.identifier.uuidString]?.Xvalue = value
                case "2102":
                    accelValues[peripheral.identifier.uuidString]?.Yvalue = value
                case "2103":
                    accelValues[peripheral.identifier.uuidString]?.Zvalue = value
                default:
                    break
                }
        case "71CBE43D-63A4-8FA2-CA20-BB87A5438CA7":
                switch uuid.uuidString {
                case "2104":
                    accelValues[peripheral.identifier.uuidString]?.Xvalue = value
                case "2105":
                    accelValues[peripheral.identifier.uuidString]?.Yvalue = value
                case "2106":
                    accelValues[peripheral.identifier.uuidString]?.Zvalue = value
                default:
                    break
            }
        default:
            break
        }
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
    
    /* --- UNUSED FUNCTIONS --- */
    // Disconnect from a peripheral
    func disconnect(peripheral: CBPeripheral) {
        centralManager.cancelPeripheralConnection(peripheral)
    }
}
