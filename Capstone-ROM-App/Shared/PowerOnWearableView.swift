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
    var body : some View {
    
        ZStack{
            // create a background with a linear gradient
            LinearGradient(gradient: Gradient(colors: [CustomColors.BackgroundColorBlue, CustomColors.BackgroundColorGreen]), startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
            
            GeometryReader{ geo in
                VStack{
                
                    Text("Please power on the following \(exercise.numberOfWearablesRequired) wearables:")
                        .font(.title)
                        .fontWeight(.bold).multilineTextAlignment(.center)
                        .frame(width: geo.size.width * 0.98, height: geo.size.height * 0.15)
                    
                    ForEach(0..<exercise.wearableIDs.count, id: \.self)
                    {
                        exerciseArray in
                        HStack{
                            ForEach(Array(zip(exercise.wearableIDs[exerciseArray], exercise.wearablesPowerOn[exerciseArray])), id: \.0)
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
                    }

                    Spacer().frame(width: geo.size.width, height: geo.size.height * 0.03)
                
                    Image(exercise.exerciseImageName).resizable().frame(width: geo.size.width * 0.67, height: geo.size.height * 0.33)
                
                    Text("Please attach the wearables to your body in the positions shown.")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .frame(width: geo.size.width * 0.95, height: geo.size.height * 0.15)
                        
                    Spacer().frame(width: geo.size.width, height: geo.size.height * 0.03)
                    
                    NavigationLink(destination: ExerciseDetailView(exercise: exercise).navigationBarTitle(exercise.exerciseName, displayMode: .inline)) {Text("View Exercise Details")}.buttonStyle(RoundedRectangleButtonStyle())
                                    
                    Spacer().frame(width: geo.size.width, height: geo.size.height * 0.03)
                }
            }
        }
    }
}

struct PowerOnWearableView_Previews: PreviewProvider {
    static var previews: some View {
        PowerOnWearableView(exercise: exercisesData[0])
    }
}
