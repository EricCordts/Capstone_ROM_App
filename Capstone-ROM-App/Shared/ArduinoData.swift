//
//  ArduinoData.swift
//  Capstone-ROM-App (iOS)
//
//  Created by Colin Regan on 3/4/22.
//

import Foundation


struct gryoscopeData {
    var Xvalue = UInt16.init(0)
    var Yvalue = UInt16.init(0)
    var Zvalue = UInt16.init(0)
}

struct accelerometerData {
    var Xvalue = UInt16.init(0)
    var Yvalue = UInt16.init(0)
    var Zvalue = UInt16.init(0)
}

struct dateTimeData {
    var month = UInt16.init(0)
    var day = UInt16.init(0)
    var hour = UInt16.init(0)
    var minute = UInt16.init(0)
    var second = UInt16.init(0)
    var millisecond = UInt16.init(0)
}
