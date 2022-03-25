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

let characteristicUUID = "D80DE551-8403-4BAE-9F78-4D2AF89FF17B"

class BluetoothViewController: UIViewController, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    /* Variables */
    @Published var isSwitchedOn = false
    @Published var isConnected: [String:Bool] = [:]
    @Published var characteristicInfo: [CBCharacteristic] = []
    @Published var soughtPeripherals: [String:CBPeripheral] = [:]
    //@Published var angle = Angle()
    @Published var imu1 = imuClass()
    @Published var imu2 = imuClass()
    var runAngleCalculation = false
    private var imu1NewData = false
    private var imu2NewData = false
    var angle = angleClass()
    
    var centralManager: CBCentralManager!
    var discoveredPeripherals: [String:CBPeripheral] = [:]
    var arduinoServices = [
        // UUID's of Arduino Services you are scanning for
        CBUUID.init(string: "2a675dfb-a1b0-4c11-9ad1-031a84594196"),
    ]
    
    /* Init */
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /* Delegate Functions */
    
    // centralManagerDidDiscover
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)
    {
        if self.discoveredPeripherals.keys.contains(peripheral.identifier.uuidString) || peripheral.state == .connected
        {
            return
        }
        
        print(peripheral.identifier.uuidString)
        self.discoveredPeripherals[peripheral.identifier.uuidString] = peripheral

        switch peripheral.identifier.uuidString {
            case arduino1PeripheralUuid:
                peripheral.delegate = self
                self.connect(peripheral: peripheral)
                imu1.id = peripheral.identifier.uuidString
                break
            case arduino2PeripheralUuid:
                peripheral.delegate = self
                self.connect(peripheral: peripheral)
                imu2.id = peripheral.identifier.uuidString
                break
            default:
                break
        }
    }

    //  centralManagerDidConnect
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // Successfully connected. Store reference to peripheral if not already done.
        self.soughtPeripherals[peripheral.identifier.uuidString] = peripheral
        isConnected[peripheral.identifier.uuidString] = true
        //self.angle.IMUs[peripheral.identifier.uuidString] = IMU()
        self.discoverServices(peripheral: peripheral)
    }
    
    // centralManagerDidFailToConnect
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if let error = error {
            print("ERROR didFailToConnect message: \(error)")
            isConnected[peripheral.identifier.uuidString] = false
            self.centralManagerDidUpdateState(central) // Called to trigger update of BluetoothView in ContentView
            return
        }
    }
    
    // centralManagerDidDisconnectPeripheral
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let error = error {
            print("ERROR didDisconnectPeripheral message: \(error)")
            self.isConnected.removeValue(forKey: peripheral.identifier.uuidString)
            self.soughtPeripherals.removeValue(forKey: peripheral.identifier.uuidString)
            //self.angle.IMUs.removeValue(forKey: peripheral.identifier.uuidString)
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

        for characteristic in characteristics {
            if characteristic.uuid.uuidString == characteristicUUID
            {
                peripheral.readValue(for: characteristic)
            }
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
            _ = myArray16.withUnsafeMutableBytes { data.copyBytes(to: $0) }
            print("Initial data: ", myArray16)
            
            if peripheral.identifier.uuidString == arduino1PeripheralUuid
            {
                imu1.customAppend(myArray16)
                imu1NewData = true
            }
            
            if peripheral.identifier.uuidString == arduino2PeripheralUuid
            {
                imu2.customAppend(myArray16)
                imu2NewData = true
            }
            
            if runAngleCalculation && imu1NewData && imu2NewData
            {
                print("Running angle")
                self.angle.updateAngle()
                imu1NewData = false
                imu2NewData = false
            }
            //self.angle.customAdd(peripheralUUIDString: peripheral.identifier.uuidString, arduinoData: myArray16)
            peripheral.readValue(for: characteristic)
        }
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
    
    // Disconnect from a peripheral
    func disconnect(peripheral: CBPeripheral) {
        self.isConnected.removeValue(forKey: peripheral.identifier.uuidString)
        self.soughtPeripherals.removeValue(forKey: peripheral.identifier.uuidString)
        //self.angle.IMUs.removeValue(forKey: peripheral.identifier.uuidString)
        centralManager.cancelPeripheralConnection(peripheral)
    }
}
