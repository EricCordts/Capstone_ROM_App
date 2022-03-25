//
//  Angle.swift
//  Capstone-ROM-App (iOS)
//
//  Created by Eric Cordts on 3/14/22.
//

import Foundation
import SwiftUI

//let arduino1PeripheralUuid = "D386AC34-D651-4AA1-CDF8-92B767DAA27E"
let arduino1PeripheralUuid = "C3548FDD-A975-0482-90EA-CD9138101212"
let arduino2PeripheralUuid = "C662D3DE-8907-BB09-50D2-694C50719E69"
/*
 class Angle : ObservableObject, Identifiable{
 var id = UUID()
 var IMUs : [String:IMU] = [:]
 
 @Published var currentAngle = Float()
 @Published var calibrated = false
 
 var jargs = [[Float]]() // polar and azimuthal angles for joint axes in local coordinates of each imu
 var j = [[Float]]() // calibrated joint axes in local coordinates of each imu
 var c = [[Float]]() // calibrated joint coordinates in local coordinates of each imu
 var angListA = [Float]()
 var angListG = [Float]()
 @Published var angList = [Float]()
 var drift = Float()
 var projx = [[Float]]() // x-axes on plane perpendicular to joint axis
 var projy = [[Float]]() // y-axes on plane perpendicular to joint axis
 var axesCalibrated : Bool = false
 
 var storeData = false
 
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
 
 func clear()
 {
 for (_, value) in IMUs
 {
 value.accelerometerData = [[Float]]()
 value.gyroscopeData = [[Float]]()
 value.dg = [[0,0,0],[0,0,0]]
 }
 }
 
 func setMaxSize(size : Int)
 {
 clear()
 for (_, value) in IMUs
 {
 value.maxSize = size
 }
 }
 
 func customAdd(peripheralUUIDString : String, arduinoData : [Int16])
 {
 assert(arduinoData.count == 6);
 
 let floatArduinoData = arduinoData.map(){Float($0)}
 
 IMUs[peripheralUUIDString]?.customAdd(newAccelerometerData: [floatArduinoData[0], floatArduinoData[1], floatArduinoData[2]], newGyroscopeData: [floatArduinoData[3], floatArduinoData[4], floatArduinoData[5]], storeData: storeData)
 
 print("AccelerationData: ", IMUs[peripheralUUIDString]?.accelerometerData ?? [[Int16]]())
 print("GyroData: ", IMUs[peripheralUUIDString]?.gyroscopeData ?? [[Int16]]())
 
 if runAngleCalculation && reallyRunAngleCalculation
 {
 print("Running angle calculation")
 }
 
 if runCalibration && reallyRunCalibration
 {
 print("Running calibration calculation")
 }
 }
 
 func len() -> Int { return min(IMUs[arduino1PeripheralUuid]?.lengthGyroscope() ?? 0,IMUs[arduino2PeripheralUuid]?.lengthGyroscope() ?? 0) }
 
 
 private func Gam(_ k: String, _ i: Int, _ ck: [Float]) -> [Float] {
 return vadd(vcross(IMUs[k]?.gyroscopeData[i] ?? [0.0, 0.0, 0.0],vcross(IMUs[k]?.gyroscopeData[i] ?? [0.0, 0.0, 0.0],ck)),vcross(IMUs[k]?.dg[i] ?? [0.0, 0.0, 0.0],ck))
 }
 
 private func Acc(_ k: Int, _ i: Int, _ peripheralUUID : String) -> [Float] {
 return vsub(IMUs[peripheralUUID]?.accelerometerData[i] ?? [0.0, 0.0, 0.0],Gam(k,i,c[k]))
 }
 
 }
 */

class angleClass : ObservableObject, Identifiable {
    var imus = [imuClass]()
    var jargs = [[Float]]() // polar and azimuthal angles for joint axes in local coordinates of each imu
    var j = [[Float]]() // calibrated joint axes in local coordinates of each imu
    var c = [[Float]]() // calibrated joint coordinates in local coordinates of each imu
    var angListA = [Float]()
    var angListG = [Float]()
    @Published var angList = [Float]()
    @Published var angle : Float = 180
    let maxAngleArraySize = 500
    var drift = Float()
    var projx = [[Float]]() // x-axes on plane perpendicular to joint axis
    var projy = [[Float]]() // y-axes on plane perpendicular to joint axis
    var storeData : Bool = false
    var axesCalibrated : Bool = false
    @Published var calibrated : Bool = false
    @Published var driftCalculated : Bool = false
    
    func len() -> Int { return min(imus[0].len(),imus[1].len()) }
        
    func setStoreData(_ newStoreDataBool : Bool) {
        storeData = newStoreDataBool
        for imu in imus { imu.setStoreData(newStoreDataBool) }
    }
    
    private func Gam(_ k: Int, _ i: Int, _ ck: [Float]) -> [Float] {
        return vadd(vcross(imus[k].g[i],vcross(imus[k].g[i],ck)),vcross(imus[k].dg[i],ck))
    }
    
    private func Acc(_ k: Int, _ i: Int) -> [Float] {
        return vsub(imus[k].a[i],Gam(k,i,c[k]))
    }
    
    ///////////// Joint Axes
    
    // immplements Gauss-Newton algorithm to step jargs closer to a calibrated value
    // still need to figure out if the axes point the same direction in space
    func calibrateJointAxes() { // make private
        let imax : Int = 1000 // arbitrarily large number of max iterations
        
        for i in 0...imax {
            let oldargs = jargs
            let pvecsDzen = puVecsDzen(jargs)
            let pvecsDazi = puVecsDazi(jargs)
            var jacobian = [[Float]]()
            var errors = [Float]()
            
            for p in 0..<len() {
                let nc0 = norm(vcross(imus[0].g[p],j[0]))
                let nc1 = norm(vcross(imus[1].g[p],j[1]))
                errors.append(nc0-nc1)
                let dTermG0 = -vdot(imus[0].g[p],j[0]) / nc0
                let dTermG1 = vdot(imus[1].g[p],j[1]) / nc1
                jacobian.append([dTermG0*vdot(imus[0].g[p],pvecsDzen[0]), dTermG0*vdot(imus[0].g[p],pvecsDazi[0]), dTermG1*vdot(imus[1].g[p],pvecsDzen[1]), dTermG1*vdot(imus[1].g[p],pvecsDazi[1])])
            }
            jargs = modpAngs(msub(jargs,svmult(mmult(pinv(jacobian),errors),0.45).chunked(2))) // step value of 0.45
            j = puVecs(jargs)
            
            if (matSqSumSq(msub(jargs,oldargs))<0.0001) { // arbitrarily small error
                var vec = [Float]()
                
                if (!((j[0]==[1,0,0])||(j[1]==[1,0,0]))) { vec = [1,0,0] }
                else if (!((j[0]==[0,1,0])||(j[1]==[0,1,0]))) { vec = [0,1,0] }
                else { vec = [0,0,1] }
                
                projx = [vcross(j[0],vec), vcross(j[1],vec)]
                projy = [vcross(j[0],projx[0]), vcross(j[1],projx[0])]
                axesCalibrated = true
                break
            }
            if (i == imax) { axesCalibrated = false } // if true, pargs did not converge in imax iterations
        }
        // temporary way to figure make the axes point the same direction in space
        // relies on the fact that the z-axis should project onto the same half-plane
        if ((j[0][2]>0 && j[1][2]<0)||(j[0][2]<0 && j[1][2]>0)) { //
            j[1] = svmult(j[1],-1)
        }
    }
    
    ////////////// Coordinates
    
    // immplements Gauss-Newton algorithm to step c closer to a calibrated value
    func calibrateCoordinates() {
        if (axesCalibrated) {
            let imax : Int = 1000 // arbitrarily large number of max iterations
            
            for i in 0...imax {
                let oldc = c
                var jacobian = [[Float]]()
                var errors = [Float]()
                
                for p in 2..<len()-2 {
                    errors.append(norm(Acc(0,p)) - norm(Acc(1,p)))
                    let An0 = svmult(normv(Acc(0,p)),-1)
                    let An1 = normv(Acc(1,p))
                    jacobian.append([vdot(An0,Gam(0,p,[1,0,0])), vdot(An0,Gam(0,p,[0,1,0])), vdot(An0,Gam(0,p,[0,0,1])), vdot(An1,Gam(1,p,[1,0,0])), vdot(An1,Gam(1,p,[0,1,0])), vdot(An1,Gam(1,p,[0,0,1]))])
                }
                c = msub(c,svmult(mmult(pinv(jacobian),errors),0.45).chunked(3)) // step value of 0.45
                if (matSqSumSq(msub(c,oldc))<0.0001) { // arbitrarily small error
                    calibrated = true
                    break
                }
                if (i==imax) { calibrated = false } // if true, c did not converge in imax iterations
            }
            c = msub(c,smmult(j,0.5*(vdot(c[0],j[0])+vdot(c[1],j[1]))))
        }
        else { calibrated = false }
    }
    
    ////////////// Angle
    
    private func deltaAngG(_ i: Int) -> Float {
        return vdot(imus[0].g[i],j[0])-vdot(imus[1].g[i],j[1])
    }
    
    private func angG(_ i: Int) -> Float {
        return angListG[i-1] + deltaAngG(i)
    }
    
    private func angA(_ i: Int) -> Float {
        let nAcc = [Acc(0,i), Acc(1,i)]
        return 180.0*acos(vdot(normv([vdot(nAcc[0],projx[0]),vdot(nAcc[0],projy[0])]),normv([vdot(nAcc[1],projx[1]),vdot(nAcc[1],projy[1])])))/Float.pi
    }
    
    func calAngList() { // make private
        let t : Float = 0.01 // value can be changed between 0 and 1 to weight sensor fusion
        angListG.append(deltaAngG(0))
        angListA.append(angA(0))
        angList.append(t*angListA[0] + (1-t)*(angListG[0]))
        for i in 1..<len()-2 {
            angListG.append(angG(i))
            angListA.append(angA(i))
            angList.append(t*angListA[i] + (1-t)*(angList[i-1] + deltaAngG(i)-drift))
        }
    }
    
    func updateAngle() {
        if (len()>4) {
            let t : Float = 0.01 // value can be changed between 0 and 1 to weight sensor fusion
            let index = imus[0].getMaxLen()-3
            angle = t*angA(index) + (1-t)*(angle + deltaAngG(index)-drift)
            if angList.count == maxAngleArraySize
            {
                angList.removeFirst()
            }
            angList.append(angle)
        }
    }
    
    //////////////// Calibration
    
    // call before collecting data for calibration
    func prepCalibration() {
        setStoreData(false)
        jargs = [[0.5,0.5],[0.5,0.5]] // arbitrary starting values
        j = puVecs(jargs)
        c = [[0.1,0.1,0.1],[0.1,0.1,0.1]] // arbitrary starting values
        angListA = [Float]()
        angListG = [Float]()
        angList = [Float]()
        for imu in imus { imu.setMaxLen(100) }
        axesCalibrated = false
        calibrated = false
        setStoreData(true)
    }
    
    // call after collecting data for calibration
    func calibrate() {
        var strt = DispatchTime.now() //
        calibrateJointAxes()
        var nd = DispatchTime.now() //
        print("Time to calibrate axes (ms):",Double(nd.uptimeNanoseconds-strt.uptimeNanoseconds)/1000000.0) //
        
        strt = DispatchTime.now() //
        calibrateCoordinates()
        nd = DispatchTime.now() //
        print("Time to calibrate coordinates (ms):",Double(nd.uptimeNanoseconds-strt.uptimeNanoseconds)/1000000.0) //
        /*
         strt = DispatchTime.now() //
         calAngList()
         nd = DispatchTime.now() //
         print("Time to calculate angles: (ms)",Double(nd.uptimeNanoseconds-strt.uptimeNanoseconds)/1000000.0) //
         */
        if (calibrated) {
            print("CALIBRATED CALIBRATED")
            setStoreData(false)
        }
    }
    
    
    func prepDriftCalibration() {
        setStoreData(false)
        angListA = [Float]()
        angListG = [Float]()
        angList = [Float]()
        for imu in imus { imu.setMaxLen(100) }
        setStoreData(true)
    }
    
    func calibrateDrift() {
        angListG.append(deltaAngG(0))
        for i in 1..<len() {
            angListG.append(angG(i))
        }
        
        // Float($0)/8 is for a sampling rate of 8 Hz
        drift = mmult(pinv(transpose([[Float](repeating: 1.0, count: angListG.count),Array(0..<angListG.count).map() {Float($0)/8}])),Array(angListG[0..<angListG.count]))[1]
        //drift = mmult(pinv(transpose([[Float](repeating: 1.0, count: angListG.count),Array(0..<angListG.count).map() {Float($0)}])),Array(angListG[0..<angListG.count]))[1]
        driftCalculated = true
        setStoreData(false)
        angListG = []
        angList = []
        for imu in imus
        {
            imu.clearData()
            imu.setMaxLen(5)
        }
    }
}

