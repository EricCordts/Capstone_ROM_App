//
//  OpeningPage.swift
//  Capstone-ROM-App
//
//  Created by Eric Cordts on 1/25/22.
//

import SwiftUI

struct OpeningPage : View {
    @State private var isShowingBodyView = false
    var body : some View {
        
        ZStack{
            // create a background with a linear gradient
            LinearGradient(gradient: Gradient(colors: [CustomColors.BackgroundColorBlue, CustomColors.BackgroundColorGreen]), startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
            
            VStack{
                Spacer()
                //create a vertical stack
                Text("Rehab-O-Meter")
                    .font(.system(size: 45))
                    .fontWeight(.heavy)
                    .foregroundColor(Color.black)
                    .padding()
                    .shadow(color: Color.white, radius: 20)
                
                Spacer()
                
                // import the image of the
                // ROMSymbol
                Image("ROMSymbol").clipShape(Circle())
                    .overlay {
                            Circle().stroke(.white, lineWidth: 4)
                                }
                    .shadow(radius: 20)
                    .padding()
                
                Spacer()
                
                Text("Welcome to your home rehabilitation program. Your physical therapist thanks you!")
                    .font(.system(size: 18))
                    .multilineTextAlignment(.center).padding()
                
                Spacer()
                    
                NavigationLink(destination: ExerciseMenuPage().navigationBarTitle("Home", displayMode: .large)) {Text("Let's workout!")}.buttonStyle(RoundedRectangleButtonStyle())
                                    
                Spacer()
                BluetoothView()
            }
        }
    }
}

struct OpeningPageView_Previews: PreviewProvider {
    static var previews: some View {
        OpeningPage()
    }
}
