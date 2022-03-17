//
//  Angle.swift
//  Capstone-ROM-App (iOS)
//
//  Created by Eric Cordts on 3/14/22.
//

import Foundation

class Angle : ObservableObject, Identifiable{
    var id = UUID()
    var IMUs : [String:IMU] = [:]
    @Published var currentAngle : Float = 0.0
    var previousAngles = [Float]()
    var storeAngleData = false
    var storeCalibrationData = false
    var runAngleCalculation = false
    var runCalibration = false
    // this variable "reallyRunCalibration" is necessary because
    // the runCalibration bool gets set in an asynchronous thread.
    // These threads can turn runCalibration true even if the user
    // navigates off of the CalibrationView, so reallyRunCalibration
    // to check that we really should be running calibration on any view.
    // Similar idea for reallyRunAngleCalculation
    var reallyRunCalibration = false
    var reallyRunAngleCalculation = false
    private let maxCalculatedAngleArraySize = 500
    
    func customAdd(peripheralUUIDString : String, arduinoData : [Int16])
    {
        assert(arduinoData.count == 6);
        
        IMUs[peripheralUUIDString]?.customAdd(accelerometerData: [arduinoData[0], arduinoData[1], arduinoData[2]], gyroscopeData: [arduinoData[3], arduinoData[4], arduinoData[5]], storeAngleData: storeAngleData, storeCalibrationData: storeCalibrationData)
        
        print("AccelerationAngleData: ", IMUs[peripheralUUIDString]?.accelerometerAngleData ?? [[Int16]]())
        print("GyroAngleData: ", IMUs[peripheralUUIDString]?.gyroscopeAngleData ?? [[Int16]]())
        print("AccelerationCalibrationData: ", IMUs[peripheralUUIDString]?.accelerometerCalibrationData ?? [[Int16]]())
        print("GyroCalibrationData: ", IMUs[peripheralUUIDString]?.gyroscopeCalibrationData ?? [[Int16]]())

        if runAngleCalculation && reallyRunAngleCalculation
        {
            print("Running angle calculation")
        }
        
        if runCalibration && reallyRunCalibration
        {
            print("Running calibration calculation")
        }
    }
}
