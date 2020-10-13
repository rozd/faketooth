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

    class func faketoothSetupTestPeripherals(peripherals: [FaketoothPeripheral]? = nil, delays: FaketoothDelaySettings? = nil) {
        FaketoothSettings.delay = delays ?? FaketoothDelaySettings(
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

        CBCentralManager.simulatedPeripherals = peripherals ?? [
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

    class func faketoothDelaySettings() -> FaketoothDelaySettings {
        FaketoothDelaySettings(
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
    }

    class func faketoothSetup(peripherals: [FaketoothPeripheral]? = nil, characteristics: [FaketoothCharacteristic]? = nil, descriptors: [FaketoothDescriptor]? = nil, delay: FaketoothDelaySettings? = nil) {

        FaketoothSettings.delay = delay ?? faketoothDelaySettings()

        CBCentralManager.simulatedPeripherals = peripherals ?? [faketoothSetupPeripherals(characteristics: characteristics, descriptors: descriptors)]

    }

    class func faketoothSetupPeripherals(identifier: UUID? = nil, name: String? = nil, characteristics: [FaketoothCharacteristic]? = nil, descriptors: [FaketoothDescriptor]? = nil) -> FaketoothPeripheral {
        FaketoothPeripheral(
            identifier: identifier ?? .testPeripheral,
            name: name ?? "Test Peripheral",
            services: [
                FaketoothService(
                    uuid: .testService,
                    isPrimary: true,
                    characteristics: characteristics ?? [faketoothSetupPeripheralCharacteristic(descriptors: descriptors)]
                )
            ],
            advertisementData: nil
        )
    }

    class func faketoothSetupPeripheralCharacteristic(uuid: CBUUID? = nil, properties: CBCharacteristicProperties? = nil, descriptors: [FaketoothDescriptor]? = nil) -> FaketoothCharacteristic {
        FaketoothCharacteristic(
            uuid: uuid ?? .testCharacteristic,
            properties: properties ?? [.read],
            descriptors: descriptors ?? [faketoothSetupPeripheralCharacteristicDescriptor()],
            valueProducer: nil,
            valueHandler: nil
        )
    }

    class func faketoothSetupPeripheralCharacteristicDescriptor(uuid: CBUUID? = nil) -> FaketoothDescriptor {
        FaketoothDescriptor(
            uuid: uuid ?? .configDescriptor,
            valueProducer: nil,
            valueHandler: nil
        )
    }

    class func faketoothTearDown() {
        CBCentralManager.simulatedPeripherals = nil
    }

    // MARK: Instance methods

    func faketoothSetup(peripherals: [FaketoothPeripheral]? = nil, characteristics: [FaketoothCharacteristic]? = nil, descriptors: [FaketoothDescriptor]? = nil, delay: FaketoothDelaySettings? = nil) {
        return XCTestCase.faketoothSetup(peripherals: peripherals, characteristics: characteristics, descriptors: descriptors, delay: delay)
    }

    func faketoothSetupPeripheral(identifier: UUID? = nil, name: String? = nil, characteristics: [FaketoothCharacteristic]? = nil, descriptors: [FaketoothDescriptor]? = nil) -> FaketoothPeripheral {
        return XCTestCase.faketoothSetupPeripherals(identifier: identifier, name: name, characteristics: characteristics, descriptors: descriptors)
    }

    func faketoothSetupPeripheralCharacteristic(uuid: CBUUID? = nil, properties: CBCharacteristicProperties? = nil, descriptors: [FaketoothDescriptor]? = nil) -> FaketoothCharacteristic {
        return XCTestCase.faketoothSetupPeripheralCharacteristic(uuid: uuid, properties: properties, descriptors: descriptors)
    }

    func faketoothSetupPeripheralCharacteristicDescriptor(uuid: CBUUID? = nil) -> FaketoothDescriptor {
        return XCTestCase.faketoothSetupPeripheralCharacteristicDescriptor(uuid: uuid)
    }

    func faketoothTearDown() {
        XCTestCase.faketoothTearDown()
    }

}
