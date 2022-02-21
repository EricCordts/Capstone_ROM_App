//
//  Utilities.swift
//  Capstone-ROM-App
//
//  Created by Eric Cordts on 1/25/22.
//

import SwiftUI

// a struct that contains custom colors as defined
// in the assets. Please match the name of the color
// with the variable name
struct CustomColors {
    static let BackgroundColorBlue = Color("BackgroundColorBlue")
    static let BackgroundColorGreen = Color("BackgroundColorGreen")
}

// a custom button style
struct RoundedRectangleButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label.foregroundColor(.black).font(.system(size: 30, weight: .bold))
    .padding(15)
    .background(CustomColors.BackgroundColorBlue.cornerRadius(10))
    .shadow(color: Color.white, radius: 20)
    .scaleEffect(configuration.isPressed ? 0.90 : 1)
  }
}
