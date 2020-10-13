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

    var centralManager: CBCentralManager!
    var centralManagerDelegate: CentralManagerDelegate!

    override func setUp() {
        centralManagerDelegate = CentralManagerDelegate()
        centralManager = CBCentralManager(delegate: centralManagerDelegate, queue: nil)
    }

    override func tearDown() {
        faketoothTearDown()
        centralManagerDelegate = nil
        centralManager = nil
    }

    // MARK: Tests

    func testState() {
        XCTAssertEqual(centralManager.state, CBManagerState.unknown, "CentralManager.state should be Unknown when Faketooth is not enabled")
        faketoothSetup()
        XCTAssertEqual(centralManager.state, CBManagerState.poweredOn, "CentralManager.state should be Powered On when Faketooth is enabled")
    }

    func testScanForPeripherals() {
        faketoothSetup()

        let expectation = XCTestExpectation(description: "Scan for peripherals")

        centralManagerDelegate.onDidDiscoverPeripheral = { (peripheral: CBPeripheral, advertisementData: [String : Any], rssi: NSNumber) in
            if (peripheral.name == "Test Peripheral") {
                expectation.fulfill()
            }
        }

        centralManager.scanForPeripherals(withServices: nil, options: nil)

        wait(for: [expectation], timeout: 1.0)
    }

    func testIsScanning() {
        faketoothSetup()

        XCTAssertFalse(centralManager.isScanning, "CentralManager.isScanning property should be false on start of the test")

        centralManager.scanForPeripherals(withServices: nil, options: nil)

        XCTAssertTrue(centralManager.isScanning, "CentraManager.isScanning property didn't switch to true after scan started")

        centralManager.stopScan()

        XCTAssertFalse(centralManager.isScanning, "CentralManager.isScanning property didn't switch to false after scan stopped")

        centralManager.scanForPeripherals(withServices: nil, options: nil)

        faketoothTearDown()

        XCTAssertFalse(centralManager.isScanning)
    }

    func testRetrievePeripheralsWithIdentifiers() {
        faketoothSetup()

        let foundPeripherals = centralManager.retrievePeripherals(withIdentifiers: [UUID(uuidString: "68753A44-4D6F-1226-9C60-0050E4C00067")!])

        let hasPeripheralWithSimulatedIdentifier = foundPeripherals.contains { $0.identifier == UUID(uuidString: "68753A44-4D6F-1226-9C60-0050E4C00067")!}
        XCTAssertTrue(hasPeripheralWithSimulatedIdentifier, "Found peripherals list doesn't contain simulated peripheral")

        let hasPeripheralWithUnknownIdentifier = foundPeripherals.contains { $0.identifier == UUID(uuidString: "00000000-4D6F-1226-9C60-0050E4C00067") }
        XCTAssertFalse(hasPeripheralWithUnknownIdentifier, "Found peripherals list contains a peripheral with an identifier not used on simulation")
    }

    func testConnectPeripheral() {
        faketoothSetup()

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

    func testIsSimulated() {
        faketoothSetup()
        XCTAssertTrue(CBCentralManager.isSimulated)

        faketoothTearDown()
        XCTAssertFalse(CBCentralManager.isSimulated)
    }

    func testFaketoothMethods() {

        faketoothSetup()

        // test private stateWhenUseFaketooth property

        centralManager.perform(NSSelectorFromString("setStateWhenUseFaketooth:"), with: NSNumber(value: CBManagerState.resetting.rawValue))
        guard let stateNumber = centralManager.perform(NSSelectorFromString("stateWhenUseFaketooth"))?.takeUnretainedValue() as? NSNumber else {
            XCTFail("Can't convert value to NSNumber")
            return
        }

        guard let state = CBManagerState(rawValue: stateNumber.intValue) else {
            XCTFail("Can't convert received number to CBManagerState")
            return
        }

        XCTAssertEqual(state, CBManagerState.resetting)

        XCTAssertEqual(centralManager.state, CBManagerState.resetting)

        // test private isScanningWhenUseFaketooth property

        centralManager.perform(NSSelectorFromString("setIsScanningWhenUseFaketooth:"), with: NSNumber(booleanLiteral: true))
        guard let isScanningNumber = centralManager.perform(NSSelectorFromString("isScanningWhenUseFaketooth"))?.takeUnretainedValue() as? NSNumber else {
            XCTFail("Can't convert value to NSNumber")
            return
        }

        let isScanning = isScanningNumber.boolValue

        XCTAssertTrue(isScanning)

        XCTAssertTrue(centralManager.isScanning)
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
