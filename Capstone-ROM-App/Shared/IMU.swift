//
//  IMU.swift
//  Capstone-ROM-App (iOS)
//
//  Created by Eric Cordts on 3/14/22.
//

import Foundation

class IMU : ObservableObject, Identifiable{
    var id = UUID()
    var accelerometerAngleData = [[Int16]]()
    var gyroscopeAngleData = [[Int16]]()
    var accelerometerCalibrationData = [[Int16]]()
    var gyroscopeCalibrationData = [[Int16]]()
    let maxAngleArraySize = 5
    let maxCalibrationArraySize = 100
    
    func customAdd(accelerometerData : [Int16], gyroscopeData : [Int16], storeAngleData : Bool, storeCalibrationData : Bool)
    {
        assert(accelerometerData.count == 3);
        assert(gyroscopeData.count == 3);
        
        if storeAngleData
        {
            // since we are appending to the accelerometer and gyroscope arrays at the same
            // time, it is safe to remove first from both if one of them hits the limit. Makes it slightly more efficient
            // since we can remove an extra check
            if accelerometerAngleData.count == maxAngleArraySize
            {
                accelerometerAngleData.removeFirst()
                gyroscopeAngleData.removeFirst()
            }
            accelerometerAngleData.append(accelerometerData)
            gyroscopeAngleData.append(gyroscopeData)
        }
        
        if storeCalibrationData
        {
            if accelerometerCalibrationData.count == maxCalibrationArraySize
            {
                accelerometerCalibrationData.removeFirst()
                gyroscopeCalibrationData.removeFirst()
            }
            accelerometerCalibrationData.append(accelerometerData)
            gyroscopeCalibrationData.append(gyroscopeData)
        }
    }
}
