//
//  Exercise.swift
//  Capstone-ROM-App
//
//  Created by Eric Cordts on 1/29/22.
//

import Foundation
import SwiftUI

var modelController: ModelController!

class Exercises: ObservableObject, Identifiable{
    @Published var exerciseArray : [Exercise] = modelController.exercises
}

class Exercise : ObservableObject, Identifiable{
    var id = UUID()
    @Published var exerciseName: String = ""
    @Published var instructions: String = ""

    @Published var exerciseImageName: String = ""

    @Published var wearablePlacementImageName: String = ""
    
    @Published var numberOfSets: Int = 0
    @Published var numberOfReps: Int = 0
    
    @Published var numberOfWearablesRequired: Int = 0
    @Published var wearableIDs = [[Int]]()
    @Published var exerciseCompleted: Bool = false
    @Published var wearablesPowerOn = [[Bool]]()
    @Published var wearablesCalibrated = [[Bool]]()
    
    init(exerciseName: String, instructions: String,
         exerciseImageName: String, wearablePlacementImageName: String, numberOfSets: Int, numberOfReps: Int, numberOfWearablesRequired: Int, wearableIDs: [[Int]], exerciseCompleted: Bool, wearablesPowerOn: [[Bool]], wearablesCalibrated: [[Bool]])
    {
        self.exerciseName = exerciseName
        self.instructions = instructions
        self.exerciseImageName = exerciseImageName
        self.wearablePlacementImageName = wearablePlacementImageName
        self.numberOfSets = numberOfSets
        self.numberOfReps = numberOfReps
        self.numberOfWearablesRequired = numberOfWearablesRequired
        self.wearableIDs = wearableIDs
        self.exerciseCompleted = exerciseCompleted
        self.wearablesPowerOn = wearablesPowerOn
        self.wearablesCalibrated = wearablesCalibrated
    }
}
