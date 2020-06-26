//
//  WelcomeView.swift
//  Faketooth
//
//  Created by Max Rozdobudko on 6/15/20.
//  Copyright © 2020 Max Rozdobudko. All rights reserved.
//

import SwiftUI

struct WelcomeView: View {

    @ObservedObject var bluetooth = BluetoothManager.current

    var body: some View {
        NavigationView { 
            NavigationLink(destination: ScanningView(peripherals: BluetoothManager.current.peripherals)) {
                Text("Scan for Peripherals")
            }
            .disabled(!bluetooth.isReady)
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
