//
//  WorkoutView.swift
//  Capstone-ROM-App
//
//  Created by Eric Cordts on 2/1/22.
//

import SwiftUI
import UIKit
import ConfettiSwiftUI

struct WorkoutView : View {
    @State var counter = 0
    @State var exerciseCompleted:Bool = false
    @ObservedObject var exercise: Exercise
    @ObservedObject var bleManager: BluetoothViewController
    @ObservedObject var angle: angleClass
    
    var body : some View {
        ZStack{
            // create a background with a linear gradient
            LinearGradient(gradient: Gradient(colors: [CustomColors.BackgroundColorBlue, CustomColors.BackgroundColorGreen]), startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
            GeometryReader { geo in

            VStack{
                
                    Text(exercise.exerciseName)
                        .font(.title)
                        .fontWeight(.bold).multilineTextAlignment(.center).frame(width: geo.size.width * 0.98, height: geo.size.height * 0.1)
                    
                    Image(exercise.wearablePlacementImageOn).resizable().frame(width: geo.size.width * 0.67, height: geo.size.height * 0.28)
                    
                    ConfettiCannon(counter: $counter, num: 50, openingAngle: Angle(degrees: 0), closingAngle: Angle(degrees: 360), radius: 200, repetitions: 4, repetitionInterval: 0.85).frame(width: 0, height: 0)

                    
                    Text("\(exercise.instructions)").font(.title3)
                        .multilineTextAlignment(.center)
                        .frame(width: geo.size.width * 0.95, height: geo.size.height * 0.18)
                    
                    HStack{
                        Text("Sets left: \(exercise.numberOfSets)  |  Reps left: \(exercise.numberOfReps)").font(.title3)
                            .multilineTextAlignment(.center)
                            .frame(width: geo.size.width * 0.95, height: geo.size.height * 0.07)
                    }
                    
                    Text("Current angle: \(Int(self.angle.averageAngle))").font(.title2)
                    
                    getColorBarImage(exercise: exercise, geo: geo).overlay(
                        RoundedRectangle(cornerRadius: 5, style: .circular)
                            .frame(width: 5, height: geo.size.height * 0.08)
                            .offset(x: -(geo.size.width / 2 + 2.5) + CGFloat(self.angle.averageAngle.converting(from: getAngleRange(exerise: exercise), to: 0...Float(Int(geo.size.width)))), y: 0)
                            .foregroundColor(Color.purple)
                            .animation(.default, value: 1)
                        )
                    if !exerciseCompleted
                    {
                        Button(
                            "Finish exercise", action: {
                                exerciseCompleted = true
                            }
                        ).buttonStyle(RoundedRectangleButtonStyle())
                    }
                    else
                    {
                        Button("Return to home", action: {NavigationUtil.popToRootView()})
                        .buttonStyle(RoundedRectangleButtonStyle())
                        .onAppear
                        {
                            self.counter += 1
                            self.angle.runCalibration = false
                            self.exercise.exerciseCompleted = true
                            self.bleManager.runAngleCalculation = false
                            self.angle.clear()
                        }
                    }
                    /*
                    Button(
                        "Print angle list", action: {
                            print(angle.angList)
                        }
                    ).buttonStyle(RoundedRectangleButtonStyle())*/
                }
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
        WorkoutView(exercise: exercisesData[0], bleManager: BluetoothViewController(), angle: angleClass())
    }
}*/

func getColorBarImage(exercise: Exercise, geo: GeometryProxy) -> some View
{
    switch exercise.exerciseType {
        case .EXTENSION:
            return Image("extensionColorBar").resizable().frame(width: geo.size.width, height: geo.size.height * 0.10, alignment: .center).overlay( GeometryReader { topLevelImageGeo in
                Image(systemName: "square").resizable().frame(width: topLevelImageGeo.size.width * 0.12, height: topLevelImageGeo.size.height).foregroundColor(Color.gray).position(x: topLevelImageGeo.size.width/1.12, y: topLevelImageGeo.size.height/2)
            })
        case .FLEXION:
            return Image("flexionColorBar").resizable().frame(width: geo.size.width, height: geo.size.height * 0.10, alignment: .center).overlay( GeometryReader { topLevelImageGeo in
                Image(systemName: "square").resizable().frame(width: topLevelImageGeo.size.width * 0.12, height: topLevelImageGeo.size.height).foregroundColor(Color.gray).position(x: topLevelImageGeo.size.width/4, y: topLevelImageGeo.size.height/2)
            })
        case .ISOMETRIC:
            return Image("isometricColorBar").resizable().frame(width: geo.size.width, height: geo.size.height * 0.10, alignment: .center).overlay( GeometryReader { topLevelImageGeo in
                Image(systemName: "square").resizable().frame(width: topLevelImageGeo.size.width * 0.12, height: topLevelImageGeo.size.height).foregroundColor(Color.gray).position(x: topLevelImageGeo.size.width/2, y: topLevelImageGeo.size.height/2)
            })
        case .UNDEF:
            return Image("isometricColorBar").resizable().frame(width: geo.size.width, height: geo.size.height * 0.10, alignment: .center).overlay( GeometryReader { topLevelImageGeo in
                Image(systemName: "square").resizable().frame(width: topLevelImageGeo.size.width * 0.12, height: topLevelImageGeo.size.height).foregroundColor(Color.gray).position(x: topLevelImageGeo.size.width/1.6, y: topLevelImageGeo.size.height/2)
            })
    }
    
}

func getAngleRange(exerise: Exercise) -> ClosedRange<Float>
{
    switch exerise.exerciseType {
        case .EXTENSION:
            return 0...195
        case .FLEXION:
            return 0...180
        case .ISOMETRIC:
            return 0...180
        case .UNDEF:
            return 0...180
    }
}

/*
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
*/
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

struct NavigationUtil {
    
    static func popToRootView() {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        findNavigationController(viewController: window?.rootViewController)?
            .popToRootViewController(animated: true)
    }

    static func findNavigationController(viewController: UIViewController?) -> UINavigationController? {
        guard let viewController = viewController else {
            return nil
        }

        if let navigationController = viewController as? UINavigationController {
            return navigationController
        }

        for childViewController in viewController.children {
            return findNavigationController(viewController: childViewController)
        }

        return nil
    }
}

