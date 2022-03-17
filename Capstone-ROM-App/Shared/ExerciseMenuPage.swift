//
//  ExerciseMenuPage.swift
//  Capstone-ROM-App
//
//  Created by Eric Cordts on 1/25/22.
//

import SwiftUI

struct ExerciseMenuPage : View {
    @ObservedObject var exercises: Exercises
    @ObservedObject var bleManager: BluetoothViewController
    var body : some View {

        ZStack{
            // create a background with a linear gradient
            LinearGradient(gradient: Gradient(colors: [CustomColors.BackgroundColorBlue, CustomColors.BackgroundColorGreen]), startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
            GeometryReader{ geo in
                VStack{
                    Text("Please choose an exercise prescribed by your therapist from the list below:")
                    .font(.system(size: 20)).padding()
                    .frame(width: geo.size.width)
                
                    List(exercises.exerciseArray)
                    { exercise in
                        NavigationLink {
                            PowerOnWearableView(exercise: exercise, bleManager: bleManager).navigationBarTitle("Setup", displayMode: .inline)
                        } label:{ExerciseRow(exercise: exercise)}
                    }

                    BluetoothView(bleManager: bleManager)
                }
            }
        }.onAppear
        {
            self.bleManager.angle.runCalibration = false
            self.bleManager.angle.runAngleCalculation = false
            self.bleManager.angle.storeAngleData = false
            self.bleManager.angle.storeCalibrationData = false
            self.bleManager.angle.reallyRunCalibration = false
            self.bleManager.angle.reallyRunAngleCalculation = false
        }
    }
}

/*struct ExerciseMenuPageView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseMenuPage(exercises: Exercises())
    }
}*/
