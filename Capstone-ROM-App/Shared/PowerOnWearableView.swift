//
//  PowerOnWearableView.swift
//  Capstone-ROM-App
//
//  Created by Eric Cordts on 1/31/22.
//

import Foundation
import SwiftUI

struct PowerOnWearableView : View {
    var exercise: Exercise
    var body : some View {
        
        ZStack{
            // create a background with a linear gradient
            LinearGradient(gradient: Gradient(colors: [CustomColors.BackgroundColorBlue, CustomColors.BackgroundColorGreen]), startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
            
            VStack{
                //create a vertical stack
                Text("Please power on the following " + String(exercise.numberOfWearablesRequired) + " wearables:")
                    .font(.title)
                    .fontWeight(.bold).multilineTextAlignment(.center).padding()
                ForEach(exercise.wearableIDs, id: \.self){
                    wearableID in
                    Text("WearableID: " + String(wearableID)).font(.title2)
                    Spacer().frame(height: 10)
                }
                
                Spacer()
                
                Image("ROMSymbol").resizable().frame(width: 250, height: 250)
                
                Spacer()
                
                Text("Please attach the wearables to your body in the positions shown in the image above")
                    .font(.title3)
                    .multilineTextAlignment(.center).padding()
                
                Spacer()
                    
                NavigationLink(destination: ExerciseDetailView(exercise: exercise).navigationBarTitle(exercise.exerciseName + " Details", displayMode: .inline)) {Text("View Exercise Details")}.buttonStyle(RoundedRectangleButtonStyle())
                                    
                Spacer()
            }
        }
    }
}

struct PowerOnWearableView_Previews: PreviewProvider {
    static var previews: some View {
        PowerOnWearableView(exercise: exercises[0])
    }
}
