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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
