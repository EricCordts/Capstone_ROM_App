//
//  OpeningPage.swift
//  Capstone-ROM-App
//
//  Created by Eric Cordts on 1/25/22.
//

import SwiftUI

struct OpeningPage : View {
    @State var isActive:Bool = false
    var body : some View {
        
        ZStack{
            // create a background with a linear gradient
            LinearGradient(gradient: Gradient(colors: [CustomColors.BackgroundColorBlue, CustomColors.BackgroundColorGreen]), startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
            
            VStack{
                if !self.isActive{
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
                    .font(.title2)
                    .multilineTextAlignment(.center).padding()
                                    
                Spacer()
                }
                else
                {
                    ExerciseMenuPage().navigationBarTitle("Home", displayMode: .large)
                }
            }.onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation {
                        self.isActive = true
                    }
                }
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
