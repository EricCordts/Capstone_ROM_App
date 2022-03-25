//
//  CalibrationView.swift
//  Capstone-ROM-App
//
//  Created by Eric Cordts on 2/1/22.
//

import SwiftUI

struct CalibrationView : View {
    @ObservedObject var exercise: Exercise
    @ObservedObject var bleManager: BluetoothViewController
    @ObservedObject var angle: angleClass

    @Environment(\.presentationMode) var presentationMode
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
                        ForEach(Array(zip(exercise.wearableIDs, exercise.wearablesCalibrated)), id: \.0)
                        {
                            exerciseItem in
                            Spacer().frame(width: geo.size.width * 0.06)
                            Text("ID: \(exerciseItem.0)").font(.title2).frame(width: geo.size.width * 0.15)
                            Spacer().frame(width: geo.size.width * 0.03)
                            if exerciseItem.1
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
                    
                
                    Spacer().frame(width: geo.size.width, height: geo.size.height * 0.1)
                
                    Text("Instructions for calibration").frame(width: geo.size.width * 0.98, height: geo.size.height * 0.1)
                
                    Spacer().frame(width: geo.size.width, height: geo.size.height * 0.1)
                    
                    if !self.angle.calibrated && !self.angle.driftCalculated
                    {
                        Button(
                            "Start Calibration", action: {
                                self.angle.prepCalibration()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                                    self.angle.calibrate()
                                }
                            }
                        ).buttonStyle(RoundedRectangleButtonStyle())
                    }
                    else if self.angle.calibrated && !self.angle.driftCalculated
                    {
                        Button(
                            "Drift Calibration", action: {
                                self.angle.prepDriftCalibration()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                                    self.angle.calibrateDrift()
                                }
                            }
                        ).buttonStyle(RoundedRectangleButtonStyle())
                    }
                    else
                    {
                        Text("DONE CALIBRATION")
                    }
                    Button(
                        "Cancel Calibration", action: {self.presentationMode.wrappedValue.dismiss()}
                    ).buttonStyle(RoundedRectangleButtonStyle())
                
                    Spacer().frame(width: geo.size.width, height: geo.size.height * 0.1)
                    // temp button to navigate to next page
                    // will be replaced by automatically going to next page after all devices are calibrated
                    NavigationLink(destination: WorkoutView(exercise: exercise, bleManager: bleManager, angle: angle).navigationBarTitle(exercise.exerciseName, displayMode: .inline)) {Text("Let's workout!")}.buttonStyle(RoundedRectangleButtonStyle())

                }
            }
        }.onAppear
        {
            self.bleManager.runAngleCalculation = false
            /*self.bleManager.angle.clear()
            self.bleManager.angle.runCalibration = false
            self.bleManager.angle.runAngleCalculation = false
            self.bleManager.angle.storeData = true
            self.bleManager.angle.reallyRunCalibration = true
            self.bleManager.angle.reallyRunAngleCalculation = false
            self.bleManager.angle.setMaxSize(size: 100)
            // after approximately 10 seconds, there should be enough data collected to run calibration
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                self.bleManager.angle.runCalibration = true
            }*/
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
