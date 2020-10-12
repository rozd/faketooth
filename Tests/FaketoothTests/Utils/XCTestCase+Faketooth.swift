//
//  File 2.swift
//  
//
//  Created by Max Rozdobudko on 10/10/20.
//

import Foundation
import XCTest
@testable import Faketooth

extension XCTestCase {

    class func faketoothSetupTestPeripherals() {
        FaketoothSettings.delay = FaketoothDelaySettings(
            scanForPeripheralDelayInSeconds: 0.1,
            connectPeripheralDelayInSeconds: 0.1,
            cancelPeripheralConnectionDelayInSeconds: 1.0,
            discoverServicesDelayInSeconds: 0.1,
            discoverCharacteristicsDelayInSeconds: 0.1,
            discoverIncludedServicesDelayInSeconds: 0.1,
            discoverDescriptorsForCharacteristicDelayInSeconds: 0.1,
            readValueForCharacteristicDelayInSeconds: 0.1,
            writeValueForCharacteristicDelayInSeconds: 0.1,
            readValueForDescriptorDelayInSeconds: 0.1,
            writeValueForDescriptorDelayInSeconds: 0.1,
            setNotifyValueForCharacteristicDelayInSeconds: 0.1
        )

        CBCentralManager.simulatedPeripherals = [
            FaketoothPeripheral(
                identifier: UUID(uuidString: "68753A44-4D6F-1226-9C60-0050E4C00067")!,
                name: "Test", services: [
                    FaketoothService(
                        uuid: CBUUID(),
                        isPrimary: true,
                        characteristics: [
                            FaketoothCharacteristic(
                                uuid: CBUUID(),
                                properties: [.read, .notify],
                                descriptors: [
                                    FaketoothDescriptor(
                                        uuid: CBUUID(string: "2902"),
                                        valueProducer: { () -> Any? in
                                            return Data(capacity: 2)
                                        }
                                    )
                                ],
                                valueProducer: { return "Hello".data(using: .utf8) }
                            )
                        ]
                    )
                ],
                advertisementData: [
                    CBAdvertisementDataLocalNameKey: "Name for Advertisement"
                ]
            )
        ]
    }
}
