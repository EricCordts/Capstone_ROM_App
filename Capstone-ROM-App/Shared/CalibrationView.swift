//
//  CalibrationView.swift
//  Capstone-ROM-App
//
//  Created by Eric Cordts on 2/1/22.
//

import SwiftUI
import UIKit

struct CalibrationView : View {
    @ObservedObject var exercise: Exercise
    @ObservedObject var bleManager: BluetoothViewController
    @ObservedObject var angle: angleClass
    @State var isRunningCalibration = false
    var body : some View {
        
        ZStack{
            // create a background with a linear gradient
            LinearGradient(gradient: Gradient(colors: [CustomColors.BackgroundColorBlue, CustomColors.BackgroundColorGreen]), startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
            GeometryReader{ geo in
                VStack{
                    Text("Calibration Process")
                        .font(.title)
                        .fontWeight(.bold).multilineTextAlignment(.center).frame(width: geo.size.width * 0.98, height: geo.size.height * 0.15)
                
                    
                    HStack{
                        ForEach(exercise.wearableIDs, id: \.self)
                        {
                            wearableID in
                            Spacer().frame(width: geo.size.width * 0.06)
                            Text("Band: \(wearableID)").font(.title2).frame(width: geo.size.width * 0.20)
                            Spacer().frame(width: geo.size.width * 0.03)
                            if self.angle.calibrated
                            {
                                Image(systemName: "checkmark.square").resizable().frame(width: geo.size.width * 0.10, height: geo.size.width * 0.10)
                                    .foregroundColor(Color.green)
                            }
                            else
                            {
                                Image(systemName: "square").resizable().frame(width: geo.size.width * 0.10, height: geo.size.width * 0.10)
                                    .foregroundColor(Color.gray)
                            }
                            Spacer().frame(width: geo.size.width * 0.06)
                        }
                    }
                    
                    Text("Instructions: ").font(.title3).fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .frame(width: geo.size.width * 0.95, height: geo.size.height * 0.08)
                    Text("Flex and extend your arm within your range of motion for 10 seconds.")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .frame(width: geo.size.width * 0.95, height: geo.size.height * 0.12)
                
                    Spacer().frame(width: geo.size.width, height: geo.size.height * 0.1)
                                        
                    /*if !self.angle.calibrated && !self.angle.driftCalculated
                    {
                        Button(
                            "Drift Calibration", action: {
                                self.angle.prepDriftCalibration()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    self.angle.calibrateDrift()
                                }
                            }
                        ).buttonStyle(RoundedRectangleButtonStyle())
                    }
                    else*/ if !self.angle.calibrated && !isRunningCalibration//&& self.angle.driftCalculated
                    {
                        Button(
                            "Start Calibration", action: {
                                self.angle.prepCalibration()
                                isRunningCalibration = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                                    self.angle.calibrate()
                                    isRunningCalibration = false
                                }
                            }
                        )
                        .buttonStyle(RoundedRectangleButtonStyle())
                    }
                    else if !self.angle.calibrated && isRunningCalibration
                    {
                        ProgressView("Calibrating...").frame(width: geo.size.width, height: geo.size.height * 0.15).scaleEffect(2).font(.system(size: 12))
                    }
                    else
                    {
                        Text("Done Calibrating!").frame(width: geo.size.width, height: geo.size.height * 0.15).font(.system(size: 24))
                    }
                    
                    Spacer()
                    
                    NavigationLink(destination: WorkoutView(exercise: exercise, bleManager: bleManager, angle: angle).navigationBarTitle(exercise.exerciseName, displayMode: .inline)) {Text("Let's Workout!")}.buttonStyle(RoundedRectangleButtonStyle()).disabled(!(self.angle.calibrated))// && self.angle.driftCalculated))
                    
                    Spacer().frame(width: geo.size.width, height: geo.size.height * 0.1)
                }
            }
        }
        .onAppear
        {
            self.angle.clear()
            self.bleManager.runAngleCalculation = false
            self.angle.runCalibration = true
        }
    }
}

/*
struct CalibrationView_Previews: PreviewProvider {
    static var previews: some View {
        CalibrationView(exercise: exercisesData[0])
    }
}
*/
