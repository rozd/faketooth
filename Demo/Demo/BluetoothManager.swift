//
//  Bluetooth.swift
//  Faketooth
//
//  Created by Max Rozdobudko on 6/15/20.
//  Copyright © 2020 Max Rozdobudko. All rights reserved.
//

import Foundation
import CoreBluetooth
import Combine
import Faketooth

typealias FoundPeripheral = (peripheral: CBPeripheral, advertisementData: [String : Any])

class BluetoothManager: NSObject, ObservableObject {

    // MARK: Shared Instance

    static let current = BluetoothManager()

    // MARK: Core Bluetooth Fields

    fileprivate let centralQueue: DispatchQueue

    fileprivate var manager: CBCentralManager!

    fileprivate var bag: Set<AnyCancellable> = []

    // MARK: Outputs

    @Published var state: CBManagerState = .unknown

    @Published var isReady: Bool = false

    @Published var peripherals: [FoundPeripheral] = []

    // MARK: Lifecycle

    override init() {
        centralQueue = DispatchQueue(label: "com.iosbrain.centralQueueName", attributes: .concurrent)

        super.init()

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
                                dataProducer: { return "Hello".data(using: .utf8) },
                                properties: [.read, .notify],
                                isNotifying: true
                            )
                        ]
                    )
                ]
            )
        ]

        manager = CBCentralManager(delegate: self, queue: centralQueue)

        $state
            .map { $0 == .poweredOn }
            .assign(to: \.isReady, on: self)
            .store(in: &bag)
    }

    // MARK: Actions

    func startScan() {
        guard manager.state == .poweredOn else {
            print("Wrong manager state \(state)")
            return
        }

        guard !manager.isScanning else {
            print("Already scanning")
            return
        }

        peripherals = []

        manager.scanForPeripherals(withServices: nil, options: [
            CBCentralManagerScanOptionAllowDuplicatesKey: false
        ])
    }

    func stopScan() {
        manager.stopScan()
    }
}

// MARK: - <CBCentralManagerDelegate>

extension BluetoothManager: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        DispatchQueue.main.async {
            self.state = central.state
        }
    }

    // MARK: Discover Peripheral

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        DispatchQueue.main.async {
            self.peripherals.append((peripheral: peripheral, advertisementData: advertisementData))
        }
    }

}
