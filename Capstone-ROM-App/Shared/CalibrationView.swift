//
//  CalibrationView.swift
//  Capstone-ROM-App
//
//  Created by Eric Cordts on 2/1/22.
//

import SwiftUI

struct CalibrationView : View {
    @ObservedObject var exercise: Exercise
    @Environment(\.presentationMode) var presentationMode
    var body : some View {
        
        ZStack{
            // create a background with a linear gradient
            LinearGradient(gradient: Gradient(colors: [CustomColors.BackgroundColorBlue, CustomColors.BackgroundColorGreen]), startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
            
            VStack{
                Text("Some sort of calibration instructions filler text")
                    .font(.title)
                    .fontWeight(.bold).multilineTextAlignment(.center).padding()
                // have some sort of status next to each wearable that says it is calibrated
                ForEach(Array(zip(exercise.wearableIDs, exercise.wearablesCalibrated)), id: \.0) { exerciseItem in
                    HStack{
                        Text("WearableID: " + String(exerciseItem.0)).font(.title2)
                        if exerciseItem.1
                        {
                            Image(systemName: "checkmark.square").resizable().frame(width: 40.0, height: 40.0)
                            .foregroundColor(Color.green)
                        }
                        else
                        {
                            Image(systemName: "square").resizable().frame(width: 40.0, height: 40.0)
                                .foregroundColor(Color.gray)
                        }
                    }
                    Spacer().frame(height: 10)
                }
                
                Spacer()
                
                Button(
                    "Cancel Calibration", action: {self.presentationMode.wrappedValue.dismiss()}
                ).buttonStyle(RoundedRectangleButtonStyle())
                Spacer()
                // temp button to navigate to next page
                // will be replaced by automatically going to next page after all devices are calibrated
                NavigationLink(destination: WorkoutView(exercise: exercise).navigationBarTitle(exercise.exerciseName, displayMode: .inline)) {Text("Let's workout!")}.buttonStyle(RoundedRectangleButtonStyle())
                Spacer()

            }
        }
    }
}

struct CalibrationView_Previews: PreviewProvider {
    static var previews: some View {
        CalibrationView(exercise: exercisesData[0])
    }
}
