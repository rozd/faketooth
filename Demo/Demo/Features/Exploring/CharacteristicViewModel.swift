//
//  CharacteristicViewModel.swift
//  Faketooth
//
//  Created by Max Rozdobudko on 6/25/20.
//  Copyright © 2020 Max Rozdobudko. All rights reserved.
//

import Foundation
import Combine
import Faketooth

class CharacteristicViewModel: NSObject, ObservableObject {

    // MARK: Model

    fileprivate let characteristic: CBCharacteristic

    fileprivate var peripheral: CBPeripheral {
        return characteristic.service.peripheral
    }

    // MARK: Output

    @Published var characteristicUUID: String

    @Published var serviceUUID: String

    @Published var values: [String] = []

    let isReadSupported: Bool

    let isWriteSupported: Bool

    init(characteristic: CBCharacteristic) {
        self.characteristic = characteristic
        self.characteristicUUID = characteristic.uuid.uuidString
        self.serviceUUID = characteristic.service.uuid.uuidString
        self.isReadSupported = characteristic.properties.contains(.read)
        self.isWriteSupported = characteristic.properties.contains(.write)

        super.init()
    }

    func enter() {
        peripheral.delegate = self
    }

    func exit() {
        peripheral.delegate = nil
    }

    func readValue() {
        peripheral.readValue(for: characteristic)
    }

    func writeValue() {
        peripheral.writeValue("Hi!!".data(using: .utf8)!, for: characteristic, type: .withoutResponse)
    }
}

// MARK: - CBPeripheralDelegate

extension CharacteristicViewModel: CBPeripheralDelegate {

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value, let value = String(data: data, encoding: .utf8) else {
            values.append("nil")
            return
        }
        values.append(value)
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        peripheral.services?.forEach { peripheral.discoverCharacteristics(nil, for: $0) }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristic = service.characteristics?.first else {
            return;
        }
        peripheral.writeValue("Hello".data(using: .utf8)!, for: characteristic, type: .withoutResponse)
    }
}
