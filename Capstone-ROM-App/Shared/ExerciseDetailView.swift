//
//  ExerciseDetailView.swift
//  Capstone-ROM-App
//
//  Created by Eric Cordts on 1/29/22.
//
/*
import Foundation
import SwiftUI

struct ExerciseDetailView: View {
    @ObservedObject var exercise: Exercise
    @ObservedObject var bleManager: BluetoothViewController
    @ObservedObject var angle: angleClass

    var body: some View {

        ZStack{
            // create a background with a linear gradient
            LinearGradient(gradient: Gradient(colors: [CustomColors.BackgroundColorBlue, CustomColors.BackgroundColorGreen]), startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
                
            GeometryReader { geo in

                VStack{
                    Text("\(exercise.exerciseName) Details")
                        .font(.title)
                        .fontWeight(.bold).multilineTextAlignment(.center)
                        .frame(width: geo.size.width * 0.98, height: geo.size.height * 0.15)
                    
                    Image(exercise.wearablePlacementImageOn).resizable().frame(width: geo.size.width * 0.67, height: geo.size.height * 0.40)
                    
                    Text("Please verify your wearables are in the correct positions.")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .frame(width: geo.size.width * 0.95, height: geo.size.height * 0.10)
                
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

                    Spacer().frame(height: geo.size.height * 0.1)
                    
                    NavigationLink(destination: CalibrationView(exercise: exercise, bleManager: bleManager, angle: angle).navigationBarTitle("Calibration", displayMode: .inline)) {Text("Tap here to calibrate!")}.buttonStyle(RoundedRectangleButtonStyle())
                }
            }
        }.onAppear
        {
            self.angle.setStoreData(false)
            self.bleManager.runAngleCalculation = false
        }
    }
}

 struct ExerciseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseDetailView(exercise: exercisesData[0])
    }
}
*/
