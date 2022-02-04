//
//  CompletedWorkoutView.swift
//  Capstone-ROM-App
//
//  Created by Eric Cordts on 2/3/22.
//

import SwiftUI

struct CompletedWorkoutView : View {
    var exercise: Exercise
    var body : some View {
        
        ZStack{
            // create a background with a linear gradient
            LinearGradient(gradient: Gradient(colors: [CustomColors.BackgroundColorBlue, CustomColors.BackgroundColorGreen]), startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
            
            VStack{
                Text("All Done!")
                    .font(.largeTitle)
                
                NavigationLink(destination: SummaryView().navigationBarTitle("Summary", displayMode: .inline)) {Text("Go to workout summary")}.buttonStyle(RoundedRectangleButtonStyle())
            }
        }
    }
}

struct CompletedWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        CompletedWorkoutView(exercise: exercises[9])
    }
}

