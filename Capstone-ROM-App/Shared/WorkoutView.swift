//
//  WorkoutView.swift
//  Capstone-ROM-App
//
//  Created by Eric Cordts on 2/1/22.
//

import SwiftUI
import UIKit

struct WorkoutView : View { 
    @State var exercisesCompleted:Bool = false
    @State var setsCompleted = 0
    @State var repsCompleted = 0
    @State var currentTime = Time(min: 0, sec: 0, hour: 0)
    @State var reciever = Timer.publish(every: 1, on: .current, in: .default).autoconnect()
    @State var displayAngle:Bool = false

    @ObservedObject var exercise: Exercise
    @ObservedObject var bleManager: BluetoothViewController
    @ObservedObject var angle: angleClass
    
    var body : some View {
        ZStack{
            // create a background with a linear gradient
            LinearGradient(gradient: Gradient(colors: [CustomColors.BackgroundColorBlue, CustomColors.BackgroundColorGreen]), startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
            GeometryReader { geo in

            VStack{
                if exercisesCompleted
                {
                    CompletedWorkoutView()
                        .onAppear{
                            self.exercise.exerciseCompleted = true
                            self.bleManager.runAngleCalculation = false
                            self.angle.setStoreData(false)
                        }
                }
                else
                {
                    Text(exercise.exerciseName)
                        .font(.title)
                        .fontWeight(.bold).multilineTextAlignment(.center).frame(width: geo.size.width * 0.98, height: geo.size.height * 0.1)
                    
                    Image(exercise.wearablePlacementImageOn).resizable().frame(width: geo.size.width * 0.67, height: geo.size.height * 0.33)
                    
                    Text("\(exercise.instructions)").font(.title3)
                        .multilineTextAlignment(.center)
                        .frame(width: geo.size.width * 0.95, height: geo.size.height * 0.14)
                    
                    HStack{
                        Text("Sets left: \(exercise.numberOfSets - setsCompleted)  |  Reps left: \(exercise.numberOfReps - repsCompleted)").font(.title3)
                            .multilineTextAlignment(.center)
                            .frame(width: geo.size.width * 0.95, height: geo.size.height * 0.10)
                    }
                    
                    ZStack{
                        RoundedRectangle(cornerRadius: 5, style: .circular)
                            .frame(width: 5, height: geo.size.height * 0.08)
                            .offset(x: -(geo.size.width / 2 + 2.5) + getSlidingBarPosn(exercise: exercise, geo: geo, angle: angle.angle), y: 0)
                            .foregroundColor(Color.purple)
                            .animation(.default, value: 1)
                            
                    }
                    .background(
                        Image("ColorBar").resizable().frame(width: geo.size.width, height: geo.size.height * 0.10).overlay( GeometryReader { topLevelImageGeo in
                            Image(systemName: "square").resizable().frame(width: topLevelImageGeo.size.width * 0.20, height: topLevelImageGeo.size.height).foregroundColor(Color.gray).position(x: topLevelImageGeo.size.width/1.6, y: topLevelImageGeo.size.height/2)
                        })
                    )
                    
                    if displayAngle
                    {
                        //Text("\(Int(angle.angle))")
                             
                        Text("\(180 - Int(angle.angle))")
                    }
                    
                    
                    // temp button to decrease reps
                    Button(
                        "Decrease reps", action: {let result = ModifySetsReps(currentRepsCompleted: &repsCompleted, targetReps: exercise.numberOfReps, currentSetsCompleted: &setsCompleted, targetSets: exercise.numberOfSets)
                            setsCompleted = result.setsCompleted
                            repsCompleted = result.repsCompleted
                            exercisesCompleted = result.exercisesCompleted
                            
                        }
                    ).buttonStyle(RoundedRectangleButtonStyle())
                }
            }.transition(.slide).animation(.easeIn(duration: 1), value: exercisesCompleted)
            }
        }.onAppear
        {
            self.angle.calculateAccelerometerAngle()
            self.displayAngle = true
            self.bleManager.runAngleCalculation = true
        }
    }
}

/*
struct WorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutView(exercise: exercisesData[0])
    }
}
*/

func ModifySetsReps(currentRepsCompleted: inout Int, targetReps: Int, currentSetsCompleted: inout Int, targetSets: Int)->(repsCompleted: Int, setsCompleted: Int, exercisesCompleted: Bool)
{
    var exercisesCompleted : Bool = false
    if currentRepsCompleted < targetReps && currentSetsCompleted < targetSets
    {
        currentRepsCompleted += 1
    }
    if currentRepsCompleted == targetReps && currentSetsCompleted < targetSets - 1
    {
        currentRepsCompleted = 0
        currentSetsCompleted += 1
    }
    
    if currentRepsCompleted == targetReps && currentSetsCompleted == targetSets - 1
    {
        currentSetsCompleted = targetSets
        exercisesCompleted = true
    }

    return (currentRepsCompleted, currentSetsCompleted, exercisesCompleted)
}

func getSlidingBarPosn(exercise: Exercise, geo: GeometryProxy, angle: Float) -> CGFloat {
    
    switch exercise.exerciseType {
    case .EXTENSION:
        if (160 - angle) < 160 {
            if (160 - angle) > 0 {
                return CGFloat(angle.converting(from: 0...160, to: 0...Float(Int(geo.size.width))))
            } else {
                return 0
            }
        } else {
            return geo.size.width
        }
    case .FLEXION:
        if angle < 180 {
            if angle > 0 {
                return 180 - CGFloat(angle.converting(from: 0...180, to: 0...Float(Int(geo.size.width))))
            } else {
                return 0
            }
        } else {
            return geo.size.width
        }
    case .ISOMETRIC:
        if (150 - angle) < 150 {
            if (150 - angle) > 0 {
                return geo.size.width - CGFloat(angle.converting(from: 0...150, to: 0...Float(Int(geo.size.width))))
            } else {
                return 0
            }
        } else {
            return geo.size.width
        }
    case .UNDEF:
        return 0
    }
}

struct Time {
    var min : Int
    var sec : Int
    var hour : Int
}

extension FloatingPoint {
    func converting(from input: ClosedRange<Self>, to output: ClosedRange<Self>) -> Self {
        let x = (output.upperBound - output.lowerBound) * (self - input.lowerBound)
        let y = (input.upperBound - input.lowerBound)
        return x / y + output.lowerBound
    }
}

extension BinaryInteger {
    func converting(from input: ClosedRange<Self>, to output: ClosedRange<Self>) -> Self {
        let x = (output.upperBound - output.lowerBound) * (self - input.lowerBound)
        let y = (input.upperBound - input.lowerBound)
        return x / y + output.lowerBound
    }
}
