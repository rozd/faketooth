//
//  File.swift
//  
//
//  Created by Max Rozdobudko on 10/5/20.
//

import XCTest
@testable import Faketooth

final class CBCentralManagerTests: XCTestCase {

    static var allTests = [
        ("testExample", test_scanForPeripherals),
    ]

    override class func setUp() {
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
                identifier: UUID(),
                name: "Test", services: [
                    FaketoothService(
                        uuid: CBUUID(),
                        isPrimary: true,
                        characteristics: [
                            FaketoothCharacteristic(
                                uuid: CBUUID(),
                                valueProducer: { return "Hello".data(using: .utf8) },
                                properties: [.read, .notify],
                                descriptors: [
                                    FaketoothDescriptor(
                                        uuid: CBUUID(string: "2902"),
                                        valueProducer: { () -> Any? in
                                            return Data(capacity: 2)
                                        }
                                    )
                                ]
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

    var centralManager: CBCentralManager!
    var centralManagerDelegate: CentralManagerDelegate!

    override func setUp() {
        centralManagerDelegate = CentralManagerDelegate()
        centralManager = CBCentralManager(delegate: centralManagerDelegate, queue: nil)
    }

    override func tearDown() {
        centralManagerDelegate = nil
        centralManager = nil
    }

    func test_scanForPeripherals() {
        let expectation = XCTestExpectation(description: "Scan for peripherals")

        centralManagerDelegate.onCentralManagerDidDiscoverPeripheral = { (peripheral: CBPeripheral, advertisementData: [String : Any], rssi: NSNumber) in
            if (peripheral.name == "Test") {
                expectation.fulfill()
            }
        }

        centralManager.scanForPeripherals(withServices: nil, options: nil)

        wait(for: [expectation], timeout: 1.0)
    }

}

// MARK: - CentralManagerDelegate

class CentralManagerDelegate: NSObject, CBCentralManagerDelegate {

    // centralManagerDidUpdateState(_:)

    var onCentralManagerDidUpdateState: ((_ central: CBCentralManager) -> Void)?

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        onCentralManagerDidUpdateState?(central)
    }

    // centralManager(_:didDiscover:advertisementData:rssi:)

    var onCentralManagerDidDiscoverPeripheral: ((_ peripheral: CBPeripheral, _ advertisementData: [String : Any], _ RSSI: NSNumber) -> Void)?

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        onCentralManagerDidDiscoverPeripheral?(peripheral, advertisementData, RSSI)
    }

}
