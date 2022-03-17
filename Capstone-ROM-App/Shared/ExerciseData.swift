//
//  ExerciseData.swift
//  Capstone-ROM-App
//
//  Created by Eric Cordts on 1/29/22.
//  Edited/Continued by Sarah Adamo up to 3/8/22.

import Foundation

// exercise 1 information
let exercise1Name = "Bicep Curl"
let exercise1Instruction = "Begin with your elbow extended, slowly bring your wrist up to your shoulder."
//let exercise1ImageName = "ArmImage"
let exercise1ImageName = "bicepCurl"
let exercise1WearablePlacementImageOff = "bicepCurl_gray"
let exercise1WearablePlacementImageOn = "bicepCurl_green"
let exercise1NumberOfSets = 2
let exercise1NumberOfReps = 6
let exercise1NumberOfWearablesRequired = 2
let exercise1WearableIDs = [1, 2]
let exercise1Completed = false
let exercise1WearablesPowerOn = [false, false]
let exercise1WearablesCalibrated = [false, false]
let exercise1PeripheralUUIDStrings = ["D386AC34-D651-4AA1-CDF8-92B767DAA27E", "26AA88E4-B8C5-75BF-0BC9-63255517C698"]

// exercise1
let exercise1 = Exercise(exerciseName: exercise1Name, instructions: exercise1Instruction, exerciseImageName: exercise1ImageName, wearablePlacementImageOff: exercise1WearablePlacementImageOff, wearablePlacementImageOn: exercise1WearablePlacementImageOn, numberOfSets: exercise1NumberOfSets, numberOfReps: exercise1NumberOfReps, numberOfWearablesRequired: exercise1NumberOfWearablesRequired, wearableIDs: exercise1WearableIDs, exerciseCompleted: exercise1Completed, wearablesPowerOn: exercise1WearablesPowerOn, wearablesCalibrated: exercise1WearablesCalibrated, peripheralUUIDStrings: exercise1PeripheralUUIDStrings)

// exercise 2 information
let exercise2Name = "Tricep Extension"
let exercise2ImageName = "tricepExtension"
let exercise2WearablePlacementImageOff = "tricepExtension_gray"
let exercise2WearablePlacementImageOn = "tricepExtension_green"
let exercise2NumberOfSets = 2
let exercise2NumberOfReps = 6
let exercise2NumberOfWearablesRequired = 2
let exercise2WearableIDs = [1, 2]
let exercise2Instruction = "Begin with your elbow bent with your elbow at 90 degrees, slowly straighten your elbow and bring your hand behind you."
let exercise2Completed = false
let exercise2WearablesPowerOn = [false, false]
let exercise2WearablesCalibrated = [false, false]
let exercise2PeripheralUUIDStrings = ["D386AC34-D651-4AA1-CDF8-92B767DAA27E", "26AA88E4-B8C5-75BF-0BC9-63255517C698"]

// exercise2
let exercise2 = Exercise(exerciseName: exercise2Name, instructions: exercise2Instruction, exerciseImageName: exercise2ImageName, wearablePlacementImageOff: exercise2WearablePlacementImageOff, wearablePlacementImageOn: exercise2WearablePlacementImageOff, numberOfSets: exercise2NumberOfSets, numberOfReps: exercise2NumberOfReps, numberOfWearablesRequired: exercise2NumberOfWearablesRequired, wearableIDs: exercise2WearableIDs, exerciseCompleted: exercise2Completed, wearablesPowerOn: exercise2WearablesPowerOn, wearablesCalibrated: exercise2WearablesCalibrated, peripheralUUIDStrings: exercise2PeripheralUUIDStrings)

// exercise 3 information
let exercise3Name = "Shoulder Press"
let exercise3ImageName = "shoulderPress"
let exercise3WearablePlacementImageOff = "shoulderPress_gray"
let exercise3WearablePlacementImageOn = "shoulderPress_green"
let exercise3NumberOfSets = 2
let exercise3NumberOfReps = 6
let exercise3NumberOfWearablesRequired = 2
let exercise3WearableIDs = [1, 2]
let exercise3Instruction = "Start with your elbow bent at 90 degrees with your palm facing away from you. Slowly straighten your arm over your head."
let exercise3Completed = false
let exercise3WearablesPowerOn = [false, false]
let exercise3WearablesCalibrated = [false, false]
let exercise3PeripheralUUIDStrings = ["D386AC34-D651-4AA1-CDF8-92B767DAA27E", "26AA88E4-B8C5-75BF-0BC9-63255517C698"]

// exercise3
let exercise3 = Exercise(exerciseName: exercise3Name, instructions: exercise3Instruction, exerciseImageName: exercise3ImageName, wearablePlacementImageOff: exercise3WearablePlacementImageOff, wearablePlacementImageOn: exercise3WearablePlacementImageOn, numberOfSets: exercise3NumberOfSets, numberOfReps: exercise3NumberOfReps, numberOfWearablesRequired: exercise3NumberOfWearablesRequired, wearableIDs: exercise3WearableIDs, exerciseCompleted: exercise3Completed, wearablesPowerOn: exercise3WearablesPowerOn, wearablesCalibrated: exercise3WearablesCalibrated, peripheralUUIDStrings: exercise3PeripheralUUIDStrings)

// exercise 4 information
let exercise4Name = "Lateral Rotation"
let exercise4ImageName = "lateralRotation"
let exercise4WearablePlacementImageOff = "lateralRotation_gray"
let exercise4WearablePlacementImageOn = "lateralRotation_green"
let exercise4NumberOfSets = 12
let exercise4NumberOfReps = 12
let exercise4NumberOfWearablesRequired = 2
let exercise4WearableIDs = [1, 2]
let exercise4Instruction = "Exercise4 Instruction"
let exercise4Completed = false
let exercise4WearablesPowerOn = [false, false]
let exercise4WearablesCalibrated = [false, false]
let exercise4PeripheralUUIDStrings = ["D386AC34-D651-4AA1-CDF8-92B767DAA27E", "26AA88E4-B8C5-75BF-0BC9-63255517C698"]

// exercise4
let exercise4 = Exercise(exerciseName: exercise4Name, instructions: exercise4Instruction    , exerciseImageName: exercise4ImageName, wearablePlacementImageOff: exercise4WearablePlacementImageOff, wearablePlacementImageOn: exercise4WearablePlacementImageOn, numberOfSets: exercise4NumberOfSets, numberOfReps: exercise4NumberOfReps, numberOfWearablesRequired: exercise4NumberOfWearablesRequired, wearableIDs: exercise4WearableIDs, exerciseCompleted: exercise4Completed, wearablesPowerOn: exercise4WearablesPowerOn, wearablesCalibrated: exercise4WearablesCalibrated, peripheralUUIDStrings: exercise4PeripheralUUIDStrings)


let exercisesData: [Exercise] = [
    exercise1,
    exercise2,
    exercise3,
    exercise4
]
