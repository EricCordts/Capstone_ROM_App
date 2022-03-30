//
//  CompletedWorkoutView.swift
//  Capstone-ROM-App
//
//  Created by Eric Cordts on 2/3/22.
//

import SwiftUI

struct CompletedWorkoutView : View {
    var body : some View {
        
        ZStack{
            // create a background with a linear gradient
            LinearGradient(gradient: Gradient(colors: [CustomColors.BackgroundColorBlue, CustomColors.BackgroundColorGreen]), startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
            
        GeometryReader { geo in
            VStack{
                Text("Exercise Summary:")
                    .font(.largeTitle).bold()
                    .frame(width: geo.size.width * 0.95, height: geo.size.height * 0.2)
                    .multilineTextAlignment(.center)
                
                Text("Great job!")
                    .font(.title)
                    .frame(width: geo.size.width * 0.95, height: geo.size.height * 0.15)
                    .multilineTextAlignment(.center)
                
                //put more Text here such as average angle hit during reps
                Text("Number of Total Reps: ")
                    .font(.headline)
                    .frame(width: geo.size.width * 0.95, height: geo.size.height * 0.10)
                    .multilineTextAlignment(.center)
                
                Text("Average % ROM: ")
                    .font(.headline)
                    .frame(width: geo.size.width * 0.95, height: geo.size.height * 0.30)
                    .multilineTextAlignment(.center)
                
                Button(
                    "Return to home", action: {NavigationUtil.popToRootView()}
                ).buttonStyle(RoundedRectangleButtonStyle())
                }
            }
        }
    }
}
struct CompletedWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        CompletedWorkoutView()
    }
}


import UIKit

struct NavigationUtil {
    
    static func popToRootView() {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        findNavigationController(viewController: window?.rootViewController)?
            .popToRootViewController(animated: true)
    }

    static func findNavigationController(viewController: UIViewController?) -> UINavigationController? {
        guard let viewController = viewController else {
            return nil
        }

        if let navigationController = viewController as? UINavigationController {
            return navigationController
        }

        for childViewController in viewController.children {
            return findNavigationController(viewController: childViewController)
        }

        return nil
    }
}
