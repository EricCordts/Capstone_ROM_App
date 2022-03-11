//
//  ContentView.swift
//  Shared
//
//  Created by Colin Regan on 1/20/22.
//

import SwiftUI
import CoreBluetooth

struct ContentView: View {
    @StateObject var modelController = ModelController()

    init() {
        UITableView.appearance().backgroundColor = UIColor.clear
        UITableViewCell.appearance().backgroundColor = .clear
    }
    
    private func change() {
        modelController.temp = true
    }
    var body: some View {
        NavigationView{
            ExerciseMenuPageView(modelController: .constant(modelController)).navigationBarTitle("Home", displayMode: .large)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
