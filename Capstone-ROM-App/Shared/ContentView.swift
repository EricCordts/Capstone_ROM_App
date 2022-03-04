//
//  ContentView.swift
//  Shared
//
//  Created by Colin Regan on 1/20/22.
//

import SwiftUI
import CoreBluetooth

struct ContentView: View {
    init() {
        UITableView.appearance().backgroundColor = UIColor.clear
        UITableViewCell.appearance().backgroundColor = .clear
    }
    
    @ObservedObject var exercises = Exercises()
    @ObservedObject var bleManager = BluetoothViewController()

    var body: some View {
        NavigationView{
            ExerciseMenuPage(exercises: exercises).navigationBarTitle("Home", displayMode: .large)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct BluetoothView : View {
    @StateObject var bleManager = BluetoothViewController()
    var body : some View {
        if bleManager.isSwitchedOn {
            Text("Bluetooth is switched on")
                .foregroundColor(.black)
            VStack{
                ForEach(bleManager.soughtPeripherals.map{$0.key}.indices, id: \.self) { index in
                    let peripheral = bleManager.soughtPeripherals.map{$0.value}[index]
                        if peripheral.state == CBPeripheralState.init(rawValue: 2){
                        Text("Connected to \( peripheral.name ?? "Arbitrary Arduino ") ")
                            .foregroundColor(.black)
                        
//                        Text("\(bleManager.accelValues[peripheral.identifier.uuidString]?.Xvalue ?? 1) : \(bleManager.accelValues[peripheral.identifier.uuidString]?.Yvalue ?? 1) : \(bleManager.accelValues[peripheral.identifier.uuidString]?.Zvalue ?? 1 )")
//                            .foregroundColor(.black)
                    }
                }
            }
        } else {
            Text("Bluetooth is NOT switched on")
                .foregroundColor(.red)
        }
    }
}
