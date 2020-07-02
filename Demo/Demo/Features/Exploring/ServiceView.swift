//
//  ServiceView.swift
//  Faketooth
//
//  Created by Max Rozdobudko on 6/17/20.
//  Copyright © 2020 Max Rozdobudko. All rights reserved.
//

import SwiftUI
import Faketooth

struct ServiceView: View {
    var service: CBService
    var body: some View {
        List {
            Text("Service UUID: \(service.uuid)")
            ForEach(service.characteristics ?? [], id: \.uuid) { characteristic in
                NavigationLink(destination: CharacteristicView(viewModel: CharacteristicViewModel(characteristic: characteristic))) {
                    CharacteristicRow(characteristic: characteristic)
                }
            }
        }
        .navigationBarTitle("Service")
    }
}

struct CharacteristicRow: View {
    var characteristic: CBCharacteristic
    var body: some View {
        return Text("\(characteristic.uuid)")
    }
}

struct ServiceView_Previews: PreviewProvider {
    static var previews: some View {
        ServiceView(service:
            FaketoothService(
                uuid: CBUUID(),
                isPrimary: true,
                characteristics: [

                ]
            )
        )
    }
}
