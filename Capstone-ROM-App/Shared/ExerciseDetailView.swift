//
//  ExerciseDetailView.swift
//  Capstone-ROM-App
//
//  Created by Eric Cordts on 1/29/22.
//

import Foundation
import SwiftUI

struct ExerciseDetailView: View {
    var exercise: Exercise

    var body: some View {
        ZStack{
            // create a background with a linear gradient
            LinearGradient(gradient: Gradient(colors: [CustomColors.BackgroundColorBlue, CustomColors.BackgroundColorGreen]), startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
        
            VStack(spacing: 15){
                // temporary image, to be replaced
                Image("ROMSymbol").resizable().frame(width: 250, height: 250)
                //exercise.wearablePlacementImage
                Text("Please put on the wearable in the positions as depicted in the above image.")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                Spacer().frame(height: 15)
                Text(exercise.exerciseName + " Details:").font(.largeTitle).fontWeight(.bold)
                HStack{
                    Spacer()
                    Text("Description: ")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(exercise.description)
                        .font(.title3)
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack{
                    Spacer()
                    Text("Number of Sets: ")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(String(exercise.numberOfSets))
                        .font(.title3)
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack{
                    Spacer()
                    Text("Number of Repetitions: ")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(String(exercise.numberOfReps))
                        .font(.title3)
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                NavigationLink(destination: CalibrationView(exercise: exercise).navigationBarTitle("Calibration", displayMode: .inline)) {Text("Tap here to calibrate!")}.buttonStyle(RoundedRectangleButtonStyle())
            }
        }
    }
}

struct ExerciseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseDetailView(exercise: exercises[0])
    }
}

