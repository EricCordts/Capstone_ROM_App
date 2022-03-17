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
            ExerciseMenuPage(exercises: exercises, bleManager: bleManager).navigationBarTitle("Home", displayMode: .large)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct BluetoothView : View {
    @ObservedObject var bleManager: BluetoothViewController
    var body : some View {
        if bleManager.isSwitchedOn {
            Text("Bluetooth is switched on")
                .foregroundColor(.black)
            VStack{
                ForEach(bleManager.soughtPeripherals.map{$0.key}.indices, id: \.self) { index in
                    let peripheral = bleManager.soughtPeripherals.map{$0.value}[index]
                        if peripheral.state == CBPeripheralState.connected{
                        Text("Connected to \( peripheral.name ?? "Arbitrary Arduino ") ")
                            .foregroundColor(.black)
                        
                            /*ForEach(bleManager.angleData[peripheral.identifier.uuidString] ?? [[Int16]](), id: \.self)
                            {
                                data in
                                HStack{
                                    ForEach(data, id: \.self)
                                {
                                    individual in
                                        Text(String(individual))
                                }
                                }
                            }*/
                    }
                }
            }
        } else {
            Text("Bluetooth is NOT switched on")
                .foregroundColor(.red)
        }
    }
}
