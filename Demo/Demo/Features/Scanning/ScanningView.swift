//
//  ScanningView.swift
//  Faketooth
//
//  Created by Max Rozdobudko on 6/15/20.
//  Copyright © 2020 Max Rozdobudko. All rights reserved.
//

import SwiftUI
import Faketooth

struct ScanningView: View {
    var peripherals: [FoundPeripheral]
    var body: some View {
        List(peripherals, id: \.peripheral) { peripheral in
            NavigationLink(destination: PeripheralView(peripheral: peripheral)) {
                FoundPeripheralRow(peripheral: peripheral)
            }
        }
        .navigationBarTitle("Found Peripherals")
        .onAppear {
            BluetoothManager.current.startScan()
        }
        .onDisappear {
            BluetoothManager.current.stopScan()
        }
    }
}

struct FoundPeripheralRow: View {
    var peripheral: FoundPeripheral
    var body: some View {
        Text("\(peripheral.advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? "Unnamed")")
    }
}

// MARK: - Preview

struct ScanningView_Previews: PreviewProvider {
    static var previews: some View {
        ScanningView(peripherals: [
            (peripheral: FaketoothPeripheral(), advertisementData: [String:Any]())
        ])
    }
}
