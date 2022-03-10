//
//  ArduinoData.swift
//  Capstone-ROM-App (iOS)
//
//  Created by Colin Regan on 3/4/22.
//

import Foundation


struct gryoscopeData {
    var Xvalue = Int16.init(0)
    var Yvalue = Int16.init(0)
    var Zvalue = Int16.init(0)
}

struct accelerometerData {
    var Xvalue = Int16.init(0)
    var Yvalue = Int16.init(0)
    var Zvalue = Int16.init(0)
}

struct dateTimeData {
    var month = UInt16.init(0)
    var day = UInt16.init(0)
    var hour = UInt16.init(0)
    var minute = UInt16.init(0)
    var second = UInt16.init(0)
    var millisecond = UInt16.init(0)
}

class arduino {
    var accelerometerX: [Int16] = []
    var accelerometerY: [Int16] = []
    var accelerometerZ: [Int16] = []
    
    var gyroscopeX: [Int16] = []
    var gyroscopeY: [Int16] = []
    var gyroscopeZ: [Int16] = []
}
