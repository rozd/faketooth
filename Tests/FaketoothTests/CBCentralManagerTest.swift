//
//  File.swift
//  
//
//  Created by Max Rozdobudko on 10/5/20.
//

import XCTest
@testable import Faketooth

final class CBCentralManagerTest: XCTestCase {

    static var allTests = [
        ("testExample", testScanForPeripherals),
    ]

    override class func setUp() {
        faketoothSetupTestPeripherals()
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

    // MARK: Tests

    func testState() {
        XCTAssertEqual(centralManager.state, CBManagerState.poweredOn, "CentralManager.state should be On when Faketooth is enabled")
    }

    func testScanForPeripherals() {
        let expectation = XCTestExpectation(description: "Scan for peripherals")

        centralManagerDelegate.onDidDiscoverPeripheral = { (peripheral: CBPeripheral, advertisementData: [String : Any], rssi: NSNumber) in
            if (peripheral.name == "Test") {
                expectation.fulfill()
            }
        }

        centralManager.scanForPeripherals(withServices: nil, options: nil)

        wait(for: [expectation], timeout: 1.0)
    }

    func testIsScanning() {
        XCTAssertFalse(centralManager.isScanning, "CentralManager.isScanning property should be false on start of the test")

        centralManager.scanForPeripherals(withServices: nil, options: nil)

        XCTAssertTrue(centralManager.isScanning, "CentraManager.isScanning property didn't switch to true after scan started")

        centralManager.stopScan()

        XCTAssertFalse(centralManager.isScanning, "CentralManager.isScanning property didn't switch to false after scan stopped")
    }

    func testRetrievePeripheralsWithIdentifiers() {
        let foundPeripherals = centralManager.retrievePeripherals(withIdentifiers: [UUID(uuidString: "68753A44-4D6F-1226-9C60-0050E4C00067")!])

        let hasPeripheralWithSimulatedIdentifier = foundPeripherals.contains { $0.identifier == UUID(uuidString: "68753A44-4D6F-1226-9C60-0050E4C00067")!}
        XCTAssertTrue(hasPeripheralWithSimulatedIdentifier, "Found peripherals list doesn't contain simulated peripheral")

        let hasPeripheralWithUnknownIdentifier = foundPeripherals.contains { $0.identifier == UUID(uuidString: "00000000-4D6F-1226-9C60-0050E4C00067") }
        XCTAssertFalse(hasPeripheralWithUnknownIdentifier, "Found peripherals list contains a peripheral with an identifier not used on simulation")
    }

    func testConnectPeripheral() {
        guard let peripheral = centralManager.retrievePeripherals(withIdentifiers: [UUID(uuidString: "68753A44-4D6F-1226-9C60-0050E4C00067")!]).first else {
            XCTFail("Unable to find simulated peripheral")
            return
        }

        XCTAssertEqual(peripheral.state, CBPeripheralState.disconnected, "Before connecting the peripheral should be in disconnected state")

        centralManager.connect(peripheral, options: nil)

        XCTAssertEqual(peripheral.state, CBPeripheralState.connecting, "Peripheral's state should switch to connecting after connection is started")

        let expectation = XCTestExpectation(description: "Connect to Peripheral")

        centralManagerDelegate.onDidConnectPeripheral = { _ in
            expectation.fulfill()
            XCTAssertEqual(peripheral.state, CBPeripheralState.connected, "Perpheral's state should be connected after successful connect")
        }

        wait(for: [expectation], timeout: 1.0)
    }

}

// MARK: - CentralManagerDelegate

class CentralManagerDelegate: NSObject, CBCentralManagerDelegate {

    // centralManagerDidUpdateState(_:)

    var onDidUpdateState: ((_ central: CBCentralManager) -> Void)?

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        onDidUpdateState?(central)
    }

    // centralManager(_:didDiscover:advertisementData:rssi:)

    var onDidDiscoverPeripheral: ((_ peripheral: CBPeripheral, _ advertisementData: [String : Any], _ RSSI: NSNumber) -> Void)?

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        onDidDiscoverPeripheral?(peripheral, advertisementData, RSSI)
    }

    // centralManager(_:didConnect:)

    var onDidConnectPeripheral: ((_ peripheral: CBPeripheral) -> Void)?

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        onDidConnectPeripheral?(peripheral)
    }

    // centralManager(_:didFailToConnect:error:)

    var onDidFailToConnect: ((_ peripheral: CBPeripheral, _ error: Error?) -> Void)?

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        onDidFailToConnect?(peripheral, error)
    }
}
