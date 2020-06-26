//
//  ContentView.swift
//  Demo
//
//  Created by Max Rozdobudko on 6/26/20.
//  Copyright © 2020 Max Rozdobudko. All rights reserved.
//

import SwiftUI
import Faketooth

struct ContentView: View {

    var body: some View {
        Text("Hello, World!")
    }

    func test() {
        CBCentralManager.simulatedPeripherals = []
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
