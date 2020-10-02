//
//  PeripheralView.swift
//  Faketooth
//
//  Created by Max Rozdobudko on 6/17/20.
//  Copyright © 2020 Max Rozdobudko. All rights reserved.
//

import SwiftUI
import Faketooth

struct PeripheralView: View {
    var peripheral: FoundPeripheral

    var body: some View {
        List {
            Text(peripheral.peripheral.name ?? "Unnamed")
            ForEach(peripheral.peripheral.services ?? [], id: \.uuid) { service in
                NavigationLink(destination: ServiceView(service: service)) {
                    ServiceRow(service: service)
                }
            }
        }
    }
}

struct ServiceRow: View {
    var service: CBService
    var body: some View {
        Text("\(service.uuid)")
    }
}

struct PeripheralView_Previews: PreviewProvider {
    static var previews: some View {
        PeripheralView(peripheral:
            (peripheral: FaketoothPeripheral(
                identifier: UUID(),
                name: "Test",
                services: nil,
                advertisementData: nil),
             advertisementData: [:])
        )
    }
}
