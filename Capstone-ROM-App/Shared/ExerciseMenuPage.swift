//
//  ExerciseMenuPage.swift
//  Capstone-ROM-App
//
//  Created by Eric Cordts on 1/25/22.
//

import SwiftUI

struct ExerciseMenuPage : View {
    var body : some View {
        let spacerHeight : CGFloat = 40
        ZStack{
            // create a background with a linear gradient
            LinearGradient(gradient: Gradient(colors: [CustomColors.BackgroundColorBlue, CustomColors.BackgroundColorGreen]), startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
                
            VStack(spacing: spacerHeight){
                Text("Please choose a body part to exercise from the list below")
                    .font(.system(size: 20))
                List{
                // first navigation link
                NavigationLink(destination: EmptyView()) {
                                Text("Left Arm")
                    }.buttonStyle(ExerciseMenuPageButtonStyle())
                                                
                NavigationLink(destination: EmptyView()) {
                                Text("Right Arm")
                    }.buttonStyle(ExerciseMenuPageButtonStyle())
                                                
                NavigationLink(destination: EmptyView()) {
                                Text("Torso/Back")
                    }.buttonStyle(ExerciseMenuPageButtonStyle())
                                                
                NavigationLink(destination: EmptyView()) {
                                Text("Right Leg")
                    }.buttonStyle(ExerciseMenuPageButtonStyle())
                                                
                NavigationLink(destination: EmptyView()) {
                                Text("Left Leg")
                    }.buttonStyle(ExerciseMenuPageButtonStyle())
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
