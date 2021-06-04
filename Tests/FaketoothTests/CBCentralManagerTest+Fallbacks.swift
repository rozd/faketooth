//
//  File.swift
//  
//
//  Created by Max Rozdobudko on 10/13/20.
//

import XCTest
@testable import Faketooth

extension CBCentralManagerTest {

    func testScanForPeripheralsFallbackToBluetooth() {
        let centralManager = MockCentralManager()
        let UUIDs   = [CBUUID.testService]
        let options = [CBCentralManagerScanOptionAllowDuplicatesKey: true]
        let expectation = XCTestExpectation(description: "Fallback to CoreBluetooth scanForPeripheral() method")
        centralManager.onScanForPeripheralsCallback = { pUUIDs, pOptions in
            expectation.fulfill()
            XCTAssertEqual(UUIDs, pUUIDs)
            XCTAssertEqual(options, pOptions as! [String: Bool])
        }
        centralManager.scanForPeripherals(withServices: UUIDs, options: options)
        wait(for: [expectation], timeout: 1.0)
    }

    func testStopScanFallbackToBluetooth() {
        let expectation = XCTestExpectation(description: "Fallback to CoreBluetooth stopScan() method")
        centralManager.onStopScan = {
            expectation.fulfill()
        }
        centralManager.stopScan()
        wait(for: [expectation], timeout: 1.0)
    }

    func testRetrievePeripheralsFallbackToBluetooth() {
        let identifiers = [UUID.testPeripheral]
        let expectation = XCTestExpectation(description: "Fallback to CoreBluetooth retrievePeripherals() method")
        centralManager.onRetrievePeripheralsCallback = { pIdentifiers in
            expectation.fulfill()
            XCTAssertEqual(identifiers, pIdentifiers)
        }
        _ = centralManager.retrievePeripherals(withIdentifiers: identifiers)
        wait(for: [expectation], timeout: 1.0)
    }

    func testConnectPeripheralFallbackToBluetooth() {
        let peripheral = faketoothSetupPeripheral()
        let options = [CBConnectPeripheralOptionNotifyOnConnectionKey: true]
        let expectation = XCTestExpectation(description: "Fallback to CoreBluetooth connectPeripheral() method")
        centralManager.onConnectPeripheralCallback = { pPeripheral, pOptions in
            expectation.fulfill()
            XCTAssertEqual(peripheral, pPeripheral)
            XCTAssertEqual(options, pOptions as! [String: Bool])
        }
        centralManager.connect(peripheral, options: options)
        wait(for: [expectation], timeout: 1.0)
    }

    func testCancelPeripheralConnectionFallbackToBluetooth() {
        let peripheral = faketoothSetupPeripheral()
        let expectation = XCTestExpectation(description: "Fallback to CoreBluetooth cancelPeripheralConnection() method")
        centralManager.onCancelPeripheralConnectionCallback = { pPeripheral in
            expectation.fulfill()
            XCTAssertEqual(peripheral, pPeripheral)
        }
        centralManager.cancelPeripheralConnection(peripheral)
        wait(for: [expectation], timeout: 1.0)
    }

}

// MARK: - Mocking CBCentralManager

//fileprivate class MockCentralManager: CBCentralManager {
//    @objc override func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?, options: [String : Any]? = nil) {
//        super.scanForPeripherals(withServices: serviceUUIDs, options: options)
//    }
//}

fileprivate struct AssociatedKeys {
    static var onScanForPeripheralsCallbackKey: UInt8           = 0
    static var onStopScanCallbackKey: UInt8                     = 0
    static var onRetrievePeripheralsCallbackKey: UInt8          = 0
    static var onConnectPeripheralCallbackKey: UInt8            = 0
    static var onCancelPeripheralConnectionCallbackKey: UInt8   = 0
}

class MockCentralManager: CBCentralManager {

//    override func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?, options: [String : Any]? = nil) {
//        super.scanForPeripherals(withServices: serviceUUIDs, options: options)
//    }

    override func stopScan() {
        super.stopScan()
    }
}

public extension CBCentralManager {

    // MARK: scanForPeripherals

    var onScanForPeripheralsCallback: ((_ serviceUUIDs: [CBUUID]?, _ options: [String : Any]?) -> Void)? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.onScanForPeripheralsCallbackKey) as? ([CBUUID]?, [String : Any]?) -> Void
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.onScanForPeripheralsCallbackKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    @objc func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?, options: [String : Any]? = nil) {
        onScanForPeripheralsCallback?(serviceUUIDs, options)
    }

    // MARK: stopScan

    var onStopScan: (() -> Void)? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.onStopScanCallbackKey) as? () -> Void
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.onStopScanCallbackKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    func stopScan() {
        onStopScan?()
    }

    // MARK: retrievePeripherals

    var onRetrievePeripheralsCallback: ((_ identifiers: [UUID]) -> Void)? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.onRetrievePeripheralsCallbackKey) as? ([UUID]) -> Void
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.onRetrievePeripheralsCallbackKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    @objc func retrievePeripherals(withIdentifiers identifiers: [UUID]) -> [CBPeripheral] {
        onRetrievePeripheralsCallback?(identifiers)
        return []
    }

    // MARK: connect

    var onConnectPeripheralCallback: ((_ peripheral: CBPeripheral, _ options: [String : Any]?) -> Void)? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.onConnectPeripheralCallbackKey) as? (CBPeripheral, [String : Any]?) -> Void
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.onConnectPeripheralCallbackKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    @objc func connect(_ peripheral: CBPeripheral, options: [String : Any]? = nil) {
        onConnectPeripheralCallback?(peripheral, options)
    }

    // MARK: cancelPeripheralConnection

    var onCancelPeripheralConnectionCallback: ((_ peripheral: CBPeripheral) -> Void)? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.onCancelPeripheralConnectionCallbackKey) as? (CBPeripheral) -> Void
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.onCancelPeripheralConnectionCallbackKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    func cancelPeripheralConnection(_ peripheral: CBPeripheral) {
        onCancelPeripheralConnectionCallback?(peripheral)
    }
}
