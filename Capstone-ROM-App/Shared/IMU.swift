//
//  IMU.swift
//  Capstone-ROM-App (iOS)
//
//  Created by Eric Cordts on 3/14/22.
//

import Foundation
/*
 class IMU : ObservableObject, Identifiable{
 var id = UUID()
 
 var accelerometerData = [[Float]]()
 var gyroscopeData = [[Float]]()
 var dg : [[Float]] = [[0,0,0],[0,0,0]]
 
 var maxSize = 100
 func lengthGyroscope() -> Int { return gyroscopeData.count }
 
 func customAdd(newAccelerometerData : [Float], newGyroscopeData : [Float], storeData : Bool)
 {
 assert(newAccelerometerData.count == 3);
 assert(newGyroscopeData.count == 3);
 
 if storeData
 {
 if accelerometerData.count == maxSize
 {
 accelerometerData.removeFirst()
 gyroscopeData.removeFirst()
 dg.removeFirst()
 }
 
 
 // "4*9.81" comes from the accelerometer range of 4g
 //a.append(svmult([Float(ag[0]),Float(ag[1]),Float(ag[2])],4*9.81/32768.0)) // use eventually
 // "2000" comes from the gyroscope range of 2000 dps
 //g.append(svmult([Float(ag[3]),Float(ag[4]),Float(ag[5])],2000*Float.pi/180.0/32768.0)) // use eventually
 accelerometerData.append(svmult(newAccelerometerData,9.81/100.0)) // current union requirements
 gyroscopeData.append(svmult(newGyroscopeData,Float.pi/1800.0)) // current union requirements
 if (lengthGyroscope()>4) {
 // "20" in "20/12" is for a sampling frequency of 20 Hz
 dg.append(svmult(vadd(vsub(gyroscopeData[lengthGyroscope()-5],gyroscopeData[lengthGyroscope()-1]),svmult(vsub(gyroscopeData[lengthGyroscope()-2],gyroscopeData[lengthGyroscope()-4]),8)),20/12))
 }
 }
 }
 }
 */

class imuClass : ObservableObject, Identifiable {
    var id : String = ""
    var a = [[Float]]()
    var g = [[Float]]()
    var dg : [[Float]] = [[0,0,0],[0,0,0]]
    private var maxLen = 100
    private var storeData : Bool = false
    
    func clearData() {
        a = []
        g = []
        dg = [[0,0,0],[0,0,0]]
    }
    
    func getStoreData() -> Bool { return storeData }
    func setStoreData(_ newStoreDataBool : Bool) {
        if (newStoreDataBool) { clearData() }
        storeData = newStoreDataBool
    }
    
    func getMaxLen() -> Int { return maxLen }
    func setMaxLen(_ newLen: Int) {
        clearData()
        maxLen = newLen < 5 ? 5 : newLen
    }
    
    func len() -> Int { return g.count }
    
    func customAppend(_ ag: [Int16]) {
        if (storeData) {
            assert(ag.count == 6)
            if len() == getMaxLen() {
                a.removeFirst()
                g.removeFirst()
                dg.removeFirst()
            }
            
            //print(id, a)
            //print(id, g)
            // "4*9.81" comes from the accelerometer range of 4g
            //a.append(svmult([Float(ag[0]),Float(ag[1]),Float(ag[2])],4*9.81/32768.0)) // use eventually
            // "2000" comes from the gyroscope range of 2000 dps
            //g.append(svmult([Float(ag[3]),Float(ag[4]),Float(ag[5])],2000*Float.pi/180.0/32768.0)) // use eventually
            
            a.append(svmult([Float(ag[0]),Float(ag[1]),Float(ag[2])],9.81/100.0)) // current union requirements
            g.append(svmult([Float(ag[3]),Float(ag[4]),Float(ag[5])],Float.pi/1800.0)) // current union requirements
            if (len()>4) {
                // "20" in "20/12" is for a sampling frequency of 20 Hz
                // TODO 8
                dg.append(svmult(vadd(vsub(g[len()-5],g[len()-1]),svmult(vsub(g[len()-2],g[len()-4]),8)),8/12))
            }
        }
    }
}
