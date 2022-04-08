//
//  PowerOnWearableView.swift
//  Capstone-ROM-App
//
//  Created by Eric Cordts on 1/31/22.
//

import Foundation
import SwiftUI

struct PowerOnWearableView : View {
    @ObservedObject var exercise: Exercise
    @ObservedObject var bleManager: BluetoothViewController
    @ObservedObject var angle: angleClass

    @State var count = 0
    var body : some View {
    
        ZStack{
            // create a background with a linear gradient
            LinearGradient(gradient: Gradient(colors: [CustomColors.BackgroundColorBlue, CustomColors.BackgroundColorGreen]), startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
            
            GeometryReader{ geo in
                VStack{
                
                    Text("Power on bands:")
                        .font(.title)
                        .fontWeight(.bold).multilineTextAlignment(.center)
                        .frame(width: geo.size.width * 0.98, height: geo.size.height * 0.10)
                    
                    HStack{
                        ForEach(Array(zip(exercise.wearableIDs, exercise.peripheralUUIDStrings)), id: \.0)
                        {
                            exerciseItem in
                            Spacer().frame(width: geo.size.width * 0.06)
                            Text("Band: \(exerciseItem.0)").font(.title2).frame(width: geo.size.width * 0.20)
                            Spacer().frame(width: geo.size.width * 0.03)
                            if self.bleManager.isConnected.keys.contains(exerciseItem.1)
                            {
                                Image(systemName: "checkmark.square").resizable().frame(width: geo.size.width * 0.10, height: geo.size.width * 0.10)
                                    .foregroundColor(Color.green).onAppear{
                                        count+=1
                                    }
                            }
                            else
                            {
                                Image(systemName: "square").resizable().frame(width: geo.size.width * 0.10, height: geo.size.width * 0.10)
                                    .foregroundColor(Color.gray).onAppear{
                                        if count > 0
                                        {
                                            count-=1
                                        }
                                    }
                            }
                            Spacer().frame(width: geo.size.width * 0.06)
                        }
                    }

                    Spacer().frame(width: geo.size.width, height: geo.size.height * 0.03)
                    
                    Image(count < exercise.numberOfWearablesRequired ?  exercise.wearablePlacementImageOff : exercise.wearablePlacementImageOn).resizable().frame(width: geo.size.width * 0.67, height: geo.size.height * 0.33)
                                        
                    Text("Please attach the wearables to your body in the positions shown.")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .frame(width: geo.size.width * 0.95, height: geo.size.height * 0.12)
                    
                    HStack{
                        Text("Number of Sets: ")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("\(exercise.numberOfSets)")
                            .font(.title2)
                    }
                    .frame(width: geo.size.width, height: geo.size.height * 0.06)
                
                    HStack{
                        Text("Number of Repetitions: ")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("\(exercise.numberOfReps)")
                            .font(.title2)
                    }
                    .frame(width: geo.size.width, height: geo.size.height * 0.06)
                    
                    Spacer().frame(width: geo.size.width, height: geo.size.height * 0.03)
                    
                    NavigationLink(destination: CalibrationView(exercise: exercise, bleManager: bleManager, angle: angle).navigationBarTitle("Calibration", displayMode: .inline)) {Text("Tap here to calibrate!")}.buttonStyle(RoundedRectangleButtonStyle()).disabled(count < exercise.numberOfWearablesRequired)
                                                        
                    Spacer().frame(width: geo.size.width, height: geo.size.height * 0.03)
                }
            }
        }.onAppear
        {
            if self.bleManager.isSwitchedOn && self.bleManager.isConnected.count == 0
            {
                self.bleManager.startScan()
            }
            self.angle.setStoreData(false)
            self.bleManager.runAngleCalculation = false
            self.angle.runCalibration = false
        }
    }
}

/*
struct PowerOnWearableView_Previews: PreviewProvider {
    static var previews: some View {
        PowerOnWearableView(exercise: exercisesData[0])
    }
}
*/
