//
//  ExerciseMenuPage.swift
//  Capstone-ROM-App
//
//  Created by Eric Cordts on 1/25/22.
//

import SwiftUI

struct ExerciseMenuPageView : View {
    @Binding var modelController: ModelController

    var body : some View {
        ZStack{
            // create a background with a linear gradient
            LinearGradient(gradient: Gradient(colors: [CustomColors.BackgroundColorBlue, CustomColors.BackgroundColorGreen]), startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
            GeometryReader{ geo in
                VStack{
                    Text("Please choose an exercise prescribed by your therapist from the list below:")
                    .font(.system(size: 20)).padding()
                    .frame(width: geo.size.width)
                    Text(String(modelController.temp))
                
                    List(modelController.exercises)
                    { exercise in
                        NavigationLink {
                            PowerOnWearableView(modelController: .constant(modelController), exercise: exercise).navigationBarTitle("Setup", displayMode: .inline)
                        } label:{ExerciseRow(exercise: exercise)}
                    }
                    BluetoothView()
                }
            }
        }
    }
}

//struct ExerciseMenuPageView_Previews: PreviewProvider {
//    static var previews: some View {
//        ExerciseMenuPage(exercises: Exercises())
//    }
//}
