//
//  Angle.swift
//  Capstone-ROM-App (iOS)
//
//  Created by Eric Cordts on 3/14/22.
//

import Foundation
import SwiftUI

//let arduino1PeripheralUuid = "D386AC34-D651-4AA1-CDF8-92B767DAA27E"
//let arduino1PeripheralUuid = "71CBE43D-63A4-8FA2-CA20-BB87A5438CA7"
//let arduino2PeripheralUuid = "AE4716BE-2833-2B22-E560-C5A08F0691D2"

let arduino2PeripheralUuid = "9383B5C4-F945-4428-6DEA-A9BD10374DDF"
let arduino1PeripheralUuid = "25DC990A-26E8-B07E-922D-27FC9A1372D8" // wrist
//let arduino2PeripheralUuid = "C3548FDD-A975-0482-90EA-CD9138101212" // upper arm

//let arduino2PeripheralUuid = "9383B5C4-F945-4428-6DEA-A9BD10374DDF" // wrist
//let arduino1PeripheralUuid = "7E5C150A-75E3-6236-1DA3-66F83B4355F8" // upper arm

//let arduino1PeripheralUuid = "C662D3DE-8907-BB09-50D2-694C50719E69"
//let arduino2PeripheralUuid = "0250AE8C-3DB4-A9E2-C97E-48F34194AE89"

//let arduino2PeripheralUuidWrist = "C662D3DE-8907-BB09-50D2-694C50719E69"
//let arduino1PeripheralUuidUpperArm = "0250AE8C-3DB4-A9E2-C97E-48F34194AE89"

//let arduino1PeripheralUuid = "F0EF153D-7329-4BA7-D595-4EF33BD00533"
//let arduino2PeripheralUuid = "0161EF07-1828-0AE7-AED6-67688ADD1E80"

let frequency : Float = 15.0

class angleClass : ObservableObject, Identifiable {
    var imus = [imuClass]()
    var jargs = [[Float]]() // polar and azimuthal angles for joint axes in local coordinates of each imu
    var j = [[Float]]() // calibrated joint axes in local coordinates of each imu
    var c = [[Float]]() // calibrated joint coordinates in local coordinates of each imu
    var angListA = [Float]()
    var angListG = [Float]()
    @Published var angList = [Float]()
    @Published var angle = Float()
    @Published var averageAngle = Float()
    let maxAngleArraySize = 2000
    var projx = [[Float]]() // x-axes on plane perpendicular to joint axis
    var projy = [[Float]]() // y-axes on plane perpendicular to joint axis
    var storeData : Bool = false
    var axesCalibrated : Bool = false
    @Published var calibrated : Bool = false
    @Published var driftCalculated : Bool = false
    var runCalibration : Bool = false
    var angleOffset = Float()
    
    func len() -> Int { return min(imus[0].len(),imus[1].len()) }
    
    func clear()
    {
        setStoreData(false)
        angListA = []
        angListG = []
        angList = []
        calibrated = false
        driftCalculated = false
        axesCalibrated = false
        averageAngle = Float()
        angleOffset = Float()
    }
        
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
        //if ((j[0][2]>0 && j[1][2]<0)||(j[0][2]<0 && j[1][2]>0)) { //
        if (j[0][2]*j[1][2] < 0) {
            print("In j inversion")
            j[1] = svmult(j[1],-1)
        }
        print("j = ",j)
        //if (j[0][2]>0) { j[0] = svmult(j[0],-1) }
        //if (j[1][2]>0) { j[1] = svmult(j[1],-1) }
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
            c = msub(c,smmult(j,0.45*(vdot(c[0],j[0])+vdot(c[1],j[1]))))
            /*if (c[0][0]*c[1][0] > 0) { //
                print("In c inversion")
                c[1] = svmult(c[1],-1)
            }*/
            print("c = ",c)
        }
        else { calibrated = false }
    }
    
    ////////////// Angle
    
    private func deltaAngG(_ i: Int) -> Float {
        return (vdot(imus[1].g[i],j[1]) - vdot(imus[0].g[i],j[0]))*(180.0/(Float.pi*frequency))
    }
    
    private func angG(_ i: Int) -> Float {
        return angListG[i-1] + deltaAngG(i)
    }
    
    private func angA(_ i: Int) -> Float {
        let nAcc = [Acc(0,i), Acc(1,i)]
        let a1 = normv([vdot(nAcc[0],projx[0]),vdot(nAcc[0],projy[0])])
        let a2 = normv([vdot(nAcc[1],projx[1]),vdot(nAcc[1],projy[1])])
        let a3 = 180.0*atan2(a1[0]*a2[0]+a1[1]*a2[1], a1[0]*a2[1]-a1[1]*a2[0])/Float.pi
        return mod(a3+90-angleOffset, 360)
    }
    
    func calAngList() { // make private
        let t : Float = 1.0 // value can be changed between 0 and 1 to weight sensor fusion
        angListG.append(deltaAngG(0))
        angListA.append(angA(0))
        //angList.append(t*angListA[0] + (1-t)*(angListG[0]))
        angList.append(angListA[0])
        for i in 1..<len()-2 {
            angListG.append(angG(i))
            angListA.append(angA(i))
            angList.append(t*angListA[i] + (1-t)*(angList[i-1] + deltaAngG(i)/*-drift*/))
        }
    }
    
    func updateAngle() {
        if (len()>4) {
            let t : Float = 1.0 // value can be changed between 0 and 1 to weight sensor fusion
            let index = imus[0].getMaxLen()-3
            angle = t*angA(index) + (1-t)*(angle + deltaAngG(index))
            if angList.count == maxAngleArraySize
            {
                angList.removeFirst()
            }
            angList.append(angle)
            
            if angList.count >= 5
            {
                averageAngle = (angList.suffix(5).reduce(0, +))/5
            }
        }
    }
    
    func calculateAccelerometerAngle()
    {
        if (len()>4) {
            let index = imus[0].getMaxLen()-3
            angle = angA(index)
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
        angListA = []
        angListG = []
        angList = []
        for imu in imus { imu.setMaxLen(100) }
        axesCalibrated = false
        calibrated = false
        setStoreData(true)
    }
    
    // call after collecting data for calibration
    func calibrate() {
        if runCalibration
        {
            calibrateJointAxes()
            calibrateCoordinates()
             
            if (calibrated) {
                //print("CALIBRATED CALIBRATED")
                calAngList()
                angleOffset = ((angList.reduce(0, +)/Float(angList.count)) > 180) ? 180.0 : 0.0
                setStoreData(false)
                angListA = []
                angListG = []
                angList = []
                for imu in imus
                {
                    imu.clearData()
                    imu.setMaxLen(5)
                }
                setStoreData(true)
            }
        }
    }
    
    
    func prepDriftCalibration() {
        setStoreData(false)
        angListA = []
        angListG = []
        angList = []
        for imu in imus { imu.setMaxLen(100) }
        setStoreData(true)
    }
    
    func averageColumns(_ mat: [[Float]]) -> [Float] {
        let matT = transpose(mat)
        let m : Float = Float(mat.count)
        let n = matT.count
        var means = [Float](repeating: 0.0, count: n)
        
        for i in 0..<n {
            means[i] = (1/m)*matT[i].reduce(0,+)
        }
        return means
    }
    
    func calibrateDrift() {
        /*angListG.append(deltaAngG(0))
        for i in 1..<len() {
            angListG.append(angG(i))
        }
        
        drift = mmult(pinv(transpose([[Float](repeating: 1.0, count: angListG.count),Array(0..<angListG.count).map() {Float($0)/frequency}])),Array(angListG[0..<angListG.count]))[1]
        */
        
        for imu in imus
        {
            imu.gyroDrift = averageColumns(imu.g)
        }
        
        driftCalculated = true
        setStoreData(false)
    }
}

