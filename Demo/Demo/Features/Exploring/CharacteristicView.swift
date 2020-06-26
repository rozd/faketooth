//
//  CharacteristicView.swift
//  Faketooth
//
//  Created by Max Rozdobudko on 6/17/20.
//  Copyright © 2020 Max Rozdobudko. All rights reserved.
//

import SwiftUI
import Faketooth

struct CharacteristicView: View {

    @ObservedObject var viewModel: CharacteristicViewModel

    @State private var values: String = ""
    var body: some View {
        VStack {
            Text("\(viewModel.characteristicUUID)")
                .font(.headline)
            GeometryReader { geometry in
                VStack {
                    Text("Service: \(self.viewModel.serviceUUID)")
                    Text("Values:")
                    List(self.viewModel.values, id: \.self) { value in
                        Text(value)
                    }
                    .frame(width: geometry.size.width)
                    if self.viewModel.isReadSupported {
                        Button(action: self.onRead) {
                            Text("Read")
                        }
                    }
                }
            }
        }
        .onAppear(perform: viewModel.enter)
        .onDisappear(perform: viewModel.exit)
    }

    func onRead() {
        viewModel.readValue()
    }
}

struct CharacteristicView_Previews: PreviewProvider {
    static var previews: some View {
        CharacteristicView(viewModel:
            CharacteristicViewModel(characteristic:
                FaketoothCharacteristic(
                    uuid: CBUUID(),
                    dataProducer: { nil },
                    properties: CBCharacteristicProperties.read,
                    isNotifying: false
                )
            )
        )
    }
}
