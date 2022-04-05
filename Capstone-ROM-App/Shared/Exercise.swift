//
//  Exercise.swift
//  Capstone-ROM-App
//
//  Created by Eric Cordts on 1/29/22.
//

import Foundation
import SwiftUI

enum exerciseClass {
    case EXTENSION, FLEXION, ISOMETRIC, UNDEF
}

class Exercises: ObservableObject, Identifiable{
    @Published var exerciseArray : [Exercise] = exercisesData
}

class Exercise : ObservableObject, Identifiable{
    var id = UUID()
    @Published var exerciseName: String = ""
    @Published var instructions: String = ""

    @Published var exerciseImageName: String = ""

    @Published var wearablePlacementImageOff: String = ""
    @Published var wearablePlacementImageOn: String = ""
    
    @Published var numberOfSets: Int = 0
    @Published var numberOfReps: Int = 0
    @Published var exerciseType = exerciseClass.UNDEF
    
    @Published var numberOfWearablesRequired: Int = 0
    @Published var wearableIDs = [Int]()
    @Published var exerciseCompleted: Bool = false
    @Published var wearablesPowerOn = [Bool]()
    @Published var wearablesCalibrated = [Bool]()
    @Published var peripheralUUIDStrings = [String]()
    
    init(exerciseName: String, instructions: String,
         exerciseImageName: String, wearablePlacementImageOff: String, wearablePlacementImageOn: String, numberOfSets: Int, numberOfReps: Int, exerciseType: exerciseClass, numberOfWearablesRequired: Int, wearableIDs: [Int], exerciseCompleted: Bool, wearablesPowerOn: [Bool], wearablesCalibrated: [Bool], peripheralUUIDStrings: [String])
    {
        self.exerciseName = exerciseName
        self.instructions = instructions
        self.exerciseImageName = exerciseImageName
        self.wearablePlacementImageOff = wearablePlacementImageOff
        self.wearablePlacementImageOn = wearablePlacementImageOn
        self.numberOfSets = numberOfSets
        self.numberOfReps = numberOfReps
        self.exerciseType = exerciseType
        self.numberOfWearablesRequired = numberOfWearablesRequired
        self.wearableIDs = wearableIDs
        self.exerciseCompleted = exerciseCompleted
        self.wearablesPowerOn = wearablesPowerOn
        self.wearablesCalibrated = wearablesCalibrated
        self.peripheralUUIDStrings = peripheralUUIDStrings
    }
}
