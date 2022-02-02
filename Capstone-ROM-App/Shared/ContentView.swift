//
//  ContentView.swift
//  Shared
//
//  Created by Colin Regan on 1/20/22.
//

import SwiftUI

struct ContentView: View {
    init() {
        UITableView.appearance().backgroundColor = UIColor.clear
        UITableViewCell.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        NavigationView{
            OpeningPage()
            .navigationBarHidden(true);
        }
    }
    
    @ObservedObject var bleManager = BluetoothViewController()
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct BluetoothView : View {
    @ObservedObject var bleManager = BluetoothViewController()
    var body : some View {
        if bleManager.isSwitchedOn {
            Text("Bluetooth is switched on")
                .foregroundColor(.green)
        } else {
            Text("Bluetooth is NOT switched on")
                .foregroundColor(.red)
        }
    }
}
