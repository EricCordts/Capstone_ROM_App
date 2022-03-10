//
//  ModelController.swift
//  Capstone-ROM-App (iOS)
//
//  Created by Colin Regan on 3/7/22.
//

import Foundation

// Update to represent all data shared between views
class ModelController: ObservableObject {
    @Published var temp = false

    // Exercises
    @Published var exercises: [Exercise] = [
        exercise1,
        exercise2,
        exercise3,
        exercise4,
        exercise5,
        exercise6,
        exercise7,
        exercise8,
        exercise9,
        exercise10
    ]
        
    // Bluetooth Data
    @Published var isConnected: [String:Bool] = [:]
    @Published var isCalibrated: [String:Bool] = [:]
    
    // Arduino Data
    @Published var arduinos: [String: arduino] = [:]

    func prettyprint() -> String {
        return "Model Controller Passed"
    }
}
