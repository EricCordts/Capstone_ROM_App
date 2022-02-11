//
//  SummaryView.swift
//  Capstone-ROM-App
//
//  Created by Eric Cordts on 2/4/22.
//

import SwiftUI

struct SummaryView : View {
    var body : some View {
        
        ZStack{
            // create a background with a linear gradient
            LinearGradient(gradient: Gradient(colors: [CustomColors.BackgroundColorBlue, CustomColors.BackgroundColorGreen]), startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
            
            VStack{
                Text("Summary filler text")
                Spacer()
                
                Button(
                    "Return to home", action: {NavigationUtil.popToRootView()}
                ).buttonStyle(RoundedRectangleButtonStyle())
            }
        }
    }
}

struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryView()
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
