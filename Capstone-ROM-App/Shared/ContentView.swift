//
//  ContentView.swift
//  Shared
//
//  Created by Colin Regan on 1/20/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TitlePage()
    }
    
    @ObservedObject var bleManager = BLEManager()
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct TitlePage : View {
    @State private var isShowingBodyView = false
    var body : some View {
        
        // create a navigation view so that we can
        // use the button to navigate to different
        // views
        NavigationView {
            
            ZStack{
                // create a background with a linear gradient
                LinearGradient(gradient: Gradient(colors: [CustomColors.BackgroundColorBlue, CustomColors.BackgroundColorGreen]), startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
                VStack{
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
                
                    Text("Filler text")
                
                    Spacer()
                    
                    NavigationLink(destination: Text("Second View"), isActive: $isShowingBodyView) { EmptyView() }
                        
                    Button("Let's workout") {
                            isShowingBodyView = true
                    }.buttonStyle(RoundedRectangleButtonStyle())
                                    
                    Spacer()
                }
            }
        }
    }
}

// a struct that contains custom colors as defined
// in the assets. Please match the name of the color
// with the variable name
struct CustomColors {
    static let BackgroundColorBlue = Color("BackgroundColorBlue")
    static let BackgroundColorGreen = Color("BackgroundColorGreen")
}

struct RoundedRectangleButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    HStack {
        configuration.label.foregroundColor(.black).font(.system(size: 30, weight: .bold))
    }
    .padding(15)
    .background(CustomColors.BackgroundColorBlue.cornerRadius(10))
    .shadow(color: Color.white, radius: 20)
    .scaleEffect(configuration.isPressed ? 0.90 : 1)
  }
}


