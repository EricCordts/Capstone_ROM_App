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
                            self.angle.runCalibration = false
                            self.exercise.exerciseCompleted = true
                            self.bleManager.runAngleCalculation = false
                            self.angle.clear()
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
                        Text("Sets left: \(exercise.numberOfSets)  |  Reps left: \(exercise.numberOfReps)").font(.title3)
                            .multilineTextAlignment(.center)
                            .frame(width: geo.size.width * 0.95, height: geo.size.height * 0.10)
                    }
                    
                    Text("Current angle: \(Int(angle.averageAngle))").font(.title2)
                    
                    ZStack{
                        RoundedRectangle(cornerRadius: 5, style: .circular)
                            .frame(width: 5, height: geo.size.height * 0.08)
                            .offset(x: -(geo.size.width / 2 + 2.5) + getSlidingBarPosn(exercise: exercise, geo: geo, angle: angle.averageAngle), y: 0)
                            .foregroundColor(Color.purple)
                            .animation(.default, value: 1)
                    }
                    .background(
                        Image("ColorBar").resizable().frame(width: geo.size.width, height: geo.size.height * 0.10).overlay( GeometryReader { topLevelImageGeo in
                            Image(systemName: "square").resizable().frame(width: topLevelImageGeo.size.width * 0.20, height: topLevelImageGeo.size.height).foregroundColor(Color.gray).position(x: topLevelImageGeo.size.width/1.6, y: topLevelImageGeo.size.height/2)
                        })
                    )
                    
                    Button(
                        "Finish exercise", action: {
                            exercisesCompleted = true
                        }
                    ).buttonStyle(RoundedRectangleButtonStyle())
                    /*
                    Button(
                        "Print angle list", action: {
                            print(angle.angList)
                        }
                    ).buttonStyle(RoundedRectangleButtonStyle())*/
                }
            }.transition(.slide).animation(.easeIn(duration: 1), value: exercisesCompleted)
            }
        }.onAppear
        {
            self.angle.runCalibration = false
            self.angle.calculateAccelerometerAngle()
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

func getSlidingBarPosn(exercise: Exercise, geo: GeometryProxy, angle: Float) -> CGFloat {
    
    switch exercise.exerciseType {
    case .EXTENSION:
        if (160 - angle) < 160
        {
            if (160 - angle) > 0
            {
                return CGFloat(angle.converting(from: 0...160, to: 0...Float(Int(geo.size.width))))
            }
            else
            {
                return 0
            }
        }
        else
        {
            return geo.size.width
        }
    case .FLEXION:
        if angle < 180
        {
            if angle > 0
            {
                return 180 - CGFloat(angle.converting(from: 0...180, to: 0...Float(Int(geo.size.width))))
            }
            else {
                return 0
            }
        }
        else
        {
            return geo.size.width
        }
    case .ISOMETRIC:
        if (150 - angle) < 150
        {
            if (150 - angle) > 0 {
                return geo.size.width - CGFloat(angle.converting(from: 0...150, to: 0...Float(Int(geo.size.width))))
            } else {
                return 0
            }
        }
        else
        {
            return geo.size.width
        }
    case .UNDEF:
        return 0
    }
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
