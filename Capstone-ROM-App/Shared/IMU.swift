//
//  IMU.swift
//  Capstone-ROM-App (iOS)
//
//  Created by Eric Cordts on 3/14/22.
//

import Foundation

class imuClass : ObservableObject, Identifiable {
    var id : String = ""
    var a = [[Float]]()
    var g = [[Float]]()
    var dg : [[Float]] = [[0,0,0],[0,0,0]]
    private var maxLen = 100
    private var storeData : Bool = false
    var gyroDrift : [Float] = [0, 0, 0]
    
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
            // "4*9.81" comes from the accelerometer range of 4g
            //a.append(svmult([Float(ag[0]),Float(ag[1]),Float(ag[2])],4*9.81/32768.0)) // use eventually
            // "2000" comes from the gyroscope range of 2000 dps
            //g.append(svmult([Float(ag[3]),Float(ag[4]),Float(ag[5])],2000*Float.pi/180.0/32768.0)) // use eventually
            
            a.append(svmult([Float(ag[0]),Float(ag[1]),Float(ag[2])],9.81/100.0)) // current union requirements
            g.append(vsub(svmult([Float(ag[3]),Float(ag[4]),Float(ag[5])],1/10.0), gyroDrift)) // current union requirements
            if (len()>4) {
                dg.append(svmult(vadd(vsub(g[len()-5],g[len()-1]),svmult(vsub(g[len()-2],g[len()-4]),8)),frequency/12))
            }
            
            print(id, a)
            print(id, g)
            print(id, dg)
        }
    }
}
