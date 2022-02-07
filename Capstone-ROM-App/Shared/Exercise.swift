//
//  Exercise.swift
//  Capstone-ROM-App
//
//  Created by Eric Cordts on 1/29/22.
//

import Foundation
import SwiftUI

class Exercises: ObservableObject, Identifiable{
    @Published var exerciseArray : [Exercise] = exercisesData
}

class Exercise : ObservableObject, Identifiable{
    var id = UUID()
    @Published var exerciseName: String = ""
    @Published var description: String = ""
    @Published var exerciseTip: String = ""

    @Published var exerciseImageName: String = ""

    @Published var wearablePlacementImageName: String = ""
    
    @Published var numberOfSets: Int = 0
    @Published var numberOfReps: Int = 0
    
    @Published var numberOfWearablesRequired: Int = 0
    @Published var wearableIDs = [Int]()
    @Published var exerciseCompleted: Bool = false
    
    init(exerciseName: String, description: String, exerciseTip: String,
exerciseImageName: String, wearablePlacementImageName: String, numberOfSets: Int, numberOfReps: Int, numberOfWearablesRequired: Int, wearableIDs: [Int], exerciseCompleted: Bool)
    {
        self.exerciseName = exerciseName
        self.description = description
        self.exerciseTip = exerciseTip
        self.exerciseImageName = exerciseImageName
        self.wearablePlacementImageName = wearablePlacementImageName
        self.numberOfSets = numberOfSets
        self.numberOfReps = numberOfReps
        self.numberOfWearablesRequired = numberOfWearablesRequired
        self.wearableIDs = wearableIDs
        self.exerciseCompleted = exerciseCompleted
    }
}
