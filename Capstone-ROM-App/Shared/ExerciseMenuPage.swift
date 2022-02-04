//
//  ExerciseMenuPage.swift
//  Capstone-ROM-App
//
//  Created by Eric Cordts on 1/25/22.
//

import SwiftUI

struct ExerciseMenuPage : View {
    var body : some View {
        ZStack{
            // create a background with a linear gradient
            LinearGradient(gradient: Gradient(colors: [CustomColors.BackgroundColorBlue, CustomColors.BackgroundColorGreen]), startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
            VStack(){
                Text("Please choose an exercise prescribed by your therapist from the list below:")
                    .font(.system(size: 20)).padding()
                
                List(exercises)
                { exercise in
                    NavigationLink {
                        PowerOnWearableView(exercise: exercise).navigationBarTitle("Setup", displayMode: .inline)
                    } label:{ExerciseRow(exercise: exercise)}
                }
            }
        }
    }
}

struct ExerciseMenuPageView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseMenuPage()
    }
}
